import { CfnOutput, Stack, StackProps } from 'aws-cdk-lib';
import { OpenIdConnectProvider, PolicyStatement, Role, WebIdentityPrincipal } from 'aws-cdk-lib/aws-iam';
import { Construct } from 'constructs';

export interface DeployRoleStackProps extends StackProps {
  /** `owner/name` of the GitHub repository allowed to deploy. */
  githubRepo: string;
  /** GitHub environment the role trusts; never branches or PRs. */
  githubEnvironment: string;
  /** ARN of the account's existing GitHub OIDC provider. The account baseline owns it; this stack never creates it. */
  oidcProviderArn: string;
  /** CDK bootstrap qualifier. */
  qualifier?: string;
}

const ISSUER = 'token.actions.githubusercontent.com';

/**
 * Deploy role for GitHub Actions via OIDC (no long-lived keys). It can only assume the CDK bootstrap
 * roles; real permissions sit in the CloudFormation execution role, never here.
 * Deploy once by hand with your own credentials: the pipeline cannot create its own first role.
 */
export class DeployRoleStack extends Stack {
  constructor(scope: Construct, id: string, props: DeployRoleStackProps) {
    super(scope, id, props);
    const qualifier = props.qualifier ?? 'hnb659fds';
    const provider = OpenIdConnectProvider.fromOpenIdConnectProviderArn(this, 'Provider', props.oidcProviderArn);

    const role = new Role(this, 'DeployRole', {
      roleName: `${id}-${props.githubEnvironment}`,
      assumedBy: new WebIdentityPrincipal(provider.openIdConnectProviderArn, {
        StringEquals: {
          [`${ISSUER}:aud`]: 'sts.amazonaws.com',
          [`${ISSUER}:sub`]: `repo:${props.githubRepo}:environment:${props.githubEnvironment}`,
        },
      }),
    });

    role.addToPolicy(
      new PolicyStatement({
        actions: ['sts:AssumeRole'],
        resources: ['deploy', 'file-publishing', 'image-publishing', 'lookup'].map(
          (kind) => `arn:${this.partition}:iam::${this.account}:role/cdk-${qualifier}-${kind}-role-${this.account}-${this.region}`,
        ),
      }),
    );

    new CfnOutput(this, 'DeployRoleArn', { value: role.roleArn, description: 'Set as AWS_DEPLOY_ROLE_ARN on the GitHub environment' });
  }
}
