import assert from 'node:assert/strict';
import { test } from 'node:test';
import { App } from 'aws-cdk-lib';
import { Match, Template } from 'aws-cdk-lib/assertions';
import { GithubOidcStack } from '../lib/github-oidc-stack.js';

const env = { account: '111111111111', region: 'eu-west-1' };
const base = { env, githubRepo: 'o/r', githubEnvironment: 'prod' };
const stack = (props: Partial<ConstructorParameters<typeof GithubOidcStack>[2]> = {}) =>
  Template.fromStack(new GithubOidcStack(new App(), 'Oidc', { ...base, ...props }));

type Json = Record<string, unknown>;
/** Resolves `Fn::Join` of strings and the partition ref to a plain ARN. */
function flatten(value: unknown): string {
  if (typeof value === 'string') return value;
  const v = value as { Ref?: string; 'Fn::Join'?: [string, unknown[]] };
  if (v.Ref === 'AWS::Partition') return 'aws';
  if (v['Fn::Join']) return v['Fn::Join'][1].map(flatten).join(v['Fn::Join'][0]);
  throw new Error(`unexpected intrinsic in role ARN: ${JSON.stringify(value)}`);
}
const roleOf = (t: Template) => Object.values(t.findResources('AWS::IAM::Role'))[0] as { Properties: Json };
const policyStatements = (t: Template) => (Object.values(t.findResources('AWS::IAM::Policy'))[0] as { Properties: { PolicyDocument: { Statement: Json[] } } }).Properties.PolicyDocument.Statement;

test('trust is exactly one repo+environment subject with the STS audience, and no wildcard', () => {
  const t = stack();
  const trust = (roleOf(t).Properties.AssumeRolePolicyDocument as { Statement: Json[] }).Statement;
  assert.equal(trust.length, 1);
  const [statement] = trust as [{ Action: string; Condition: Json }];
  assert.equal(statement.Action, 'sts:AssumeRoleWithWebIdentity');
  assert.deepEqual(statement.Condition, {
    StringEquals: {
      'token.actions.githubusercontent.com:aud': 'sts.amazonaws.com',
      'token.actions.githubusercontent.com:sub': 'repo:o/r:environment:prod',
    },
  });
  assert.ok(!JSON.stringify(trust).includes('*'), 'trust policy must not contain a wildcard');
  assert.ok(!JSON.stringify(trust).includes('StringLike'), 'trust must use exact matching');
});

test('the role can only assume the four CDK bootstrap roles', () => {
  const statements = policyStatements(stack());
  assert.equal(statements.length, 1);
  const [statement] = statements as [{ Effect: string; Action: string; Resource: unknown[] }];
  assert.equal(statement.Effect, 'Allow');
  assert.equal(statement.Action, 'sts:AssumeRole');
  assert.deepEqual(
    statement.Resource.map(flatten).sort(),
    ['deploy', 'file-publishing', 'image-publishing', 'lookup'].map((k) => `arn:aws:iam::111111111111:role/cdk-hnb659fds-${k}-role-111111111111-eu-west-1`).sort(),
  );
  assert.ok(!JSON.stringify(statements).includes('*'), 'permissions must not contain a wildcard');
});

test('a custom bootstrap qualifier flows into the role ARNs', () => {
  const [statement] = policyStatements(stack({ qualifier: 'myqual' })) as [{ Resource: unknown[] }];
  assert.ok(statement.Resource.map(flatten).every((arn) => arn.includes('cdk-myqual-')));
});

test('the stack creates the provider with the STS client id, or reuses an existing one', () => {
  stack().hasResourceProperties('AWS::IAM::OIDCProvider', { Url: 'https://token.actions.githubusercontent.com', ClientIdList: ['sts.amazonaws.com'] });
  const arn = 'arn:aws:iam::111111111111:oidc-provider/token.actions.githubusercontent.com';
  const reuse = stack({ existingProviderArn: arn });
  reuse.resourceCountIs('AWS::IAM::OIDCProvider', 0);
  reuse.hasResourceProperties('AWS::IAM::Role', { AssumeRolePolicyDocument: Match.objectLike({ Statement: [Match.objectLike({ Principal: { Federated: arn } })] }) });
});

test('wildcards or malformed repo and environment values are rejected', () => {
  for (const githubRepo of ['o/*', 'o/r:*', '*/r', 'o', 'o/r/extra', '']) {
    assert.throws(() => stack({ githubRepo }), /githubRepo/, githubRepo);
  }
  for (const githubEnvironment of ['*', 'prod*', 'a:b', '']) {
    assert.throws(() => stack({ githubEnvironment }), /githubEnvironment/, githubEnvironment);
  }
});

test('the role ARN is exported as an output for the AWS_DEPLOY_ROLE_ARN variable', () => {
  stack().hasOutput('DeployRoleArn', {});
});
