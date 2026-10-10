import { CfnOutput, Stack, StackProps } from 'aws-cdk-lib';
import { IOidcProvider, OidcProviderNative, PolicyStatement, Role, WebIdentityPrincipal } from 'aws-cdk-lib/aws-iam';
import { Construct } from 'constructs';

const ISSUER = 'token.actions.githubusercontent.com';
const BOOTSTRAP_ROLE_KINDS = ['deploy', 'file-publishing', 'image-publishing', 'lookup'] as const;
/** Default qualifier written by `cdk bootstrap`. */
const DEFAULT_QUALIFIER = 'hnb659fds';

export interface GithubOidcStackProps extends StackProps {
  /** `owner/name` of the GitHub repository allowed to deploy. Exact match only. */
  githubRepo: string;
  /** GitHub environment the role trusts. Never a branch or a pull request. */
  githubEnvironment: string;
  /** CDK bootstrap qualifier; must match the one used by `cdk bootstrap`. */
  qualifier?: string;
  /** Use this existing GitHub OIDC provider instead of creating one (an account can hold only one). */
  existingProviderArn?: string;
}

/**
 * Deploy role for GitHub Actions via OIDC (no long-lived keys).
 *
 * The role can only assume the CDK bootstrap roles; real permissions sit in the CloudFormation
 * execution role. Trust is exactly `repo:<owner>/<repo>:environment:<env>` with audience
 * `sts.amazonaws.com`, so required reviewers on that environment gate every deploy.
 *
 * Deploy this stack once, by hand, with admin credentials (`npm run deploy:oidc`): the pipeline
 * cannot create its own first role. An account can hold only one GitHub OIDC provider; if the
 * account already has one, pass its ARN as `existingProviderArn`.
 */
export class GithubOidcStack extends Stack {
  constructor(scope: Construct, id: string, props: GithubOidcStackProps) {
    super(scope, id, props);
    const { githubRepo, githubEnvironment, existingProviderArn } = props;
    const qualifier = props.qualifier ?? DEFAULT_QUALIFIER;

    // Defence in depth: config.ts validates too, but a wildcard here would let any branch or PR deploy.
    if (!/^[A-Za-z0-9_.-]+\/[A-Za-z0-9_.-]+$/.test(githubRepo)) throw new Error(`githubRepo must be owner/name with no wildcards (got ${githubRepo})`);
    if (!/^[A-Za-z0-9_.-]+$/.test(githubEnvironment)) throw new Error(`githubEnvironment must have no wildcards (got ${githubEnvironment})`);

    const provider: IOidcProvider = existingProviderArn
      ? OidcProviderNative.fromOidcProviderArn(this, 'Provider', existingProviderArn)
      : new OidcProviderNative(this, 'Provider', { url: `https://${ISSUER}`, clientIds: ['sts.amazonaws.com'] });

    const role = new Role(this, 'DeployRole', {
      assumedBy: new WebIdentityPrincipal(provider.oidcProviderArn, {
        StringEquals: {
          [`${ISSUER}:aud`]: 'sts.amazonaws.com',
          [`${ISSUER}:sub`]: `repo:${githubRepo}:environment:${githubEnvironment}`,
        },
      }),
    });

    role.addToPolicy(
      new PolicyStatement({
        actions: ['sts:AssumeRole'],
        resources: BOOTSTRAP_ROLE_KINDS.map((kind) => `arn:${this.partition}:iam::${this.account}:role/cdk-${qualifier}-${kind}-role-${this.account}-${this.region}`),
      }),
    );

    new CfnOutput(this, 'DeployRoleArn', { value: role.roleArn, description: 'Set as the AWS_DEPLOY_ROLE_ARN variable on the GitHub environment' });
  }
}
