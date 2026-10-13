import assert from 'node:assert/strict';
import { test } from 'node:test';
import { App } from 'aws-cdk-lib';
import { Template } from 'aws-cdk-lib/assertions';
import { DeployRoleStack } from '../lib/deploy-role-stack.js';

const oidcProviderArn = 'arn:aws:iam::111111111111:oidc-provider/token.actions.githubusercontent.com';
const build = () =>
  Template.fromStack(
    new DeployRoleStack(new App(), 'CanonAppDeploy', {
      githubRepo: 'acme/widgets',
      githubEnvironment: 'prod',
      oidcProviderArn,
      env: { account: '111111111111', region: 'us-east-1' },
    }),
  );

test('references the OIDC provider and never creates it', () => {
  const t = build();
  t.resourceCountIs('Custom::AWSCDKOpenIdConnectProvider', 0);
  t.resourceCountIs('AWS::IAM::OIDCProvider', 0);
  assert.match(JSON.stringify(t.toJSON()), new RegExp(oidcProviderArn));
});

test('trust is scoped to repo and environment, not branches', () => {
  const trust = JSON.stringify(build().findResources('AWS::IAM::Role'));
  assert.match(trust, /repo:acme\/widgets:environment:prod/);
  assert.doesNotMatch(trust, /:\*/);
});

test('may only assume the four CDK bootstrap roles', () => {
  const policies = Object.values(build().findResources('AWS::IAM::Policy'));
  const statements = policies.flatMap((p: any) => p.Properties.PolicyDocument.Statement);
  assert.equal(statements.length, 1);
  assert.deepEqual(statements[0].Action, 'sts:AssumeRole');
  assert.equal(statements[0].Resource.length, 4);
  for (const arn of statements[0].Resource) assert.match(JSON.stringify(arn), /role\/cdk-hnb659fds-(deploy|file-publishing|image-publishing|lookup)-role-/);
});
