import assert from 'node:assert/strict';
import { test } from 'node:test';
import { fileURLToPath } from 'node:url';
import { App, Aspects, Stack } from 'aws-cdk-lib';
import { Annotations, Match, Template } from 'aws-cdk-lib/assertions';
import { CfnNatGateway, CfnInstance } from 'aws-cdk-lib/aws-ec2';
import { AttributeType, BillingMode, Table } from 'aws-cdk-lib/aws-dynamodb';
import { buildApp } from '../lib/app.js';
import { FreeTierGuard } from '../lib/free-tier-guard.js';
import { AppStack } from '../lib/stack.js';

const lambdaDir = fileURLToPath(new URL('../lambda', import.meta.url));
const config = { region: 'us-east-1', deploy: 'merge' as const, budgetUsd: 5, budgetEmail: 'me@corp.test', envName: 'prod', allowPaid: false };

test('default stack synthesises with no cdk-nag or guardrail errors', () => {
  const app = buildApp(config, lambdaDir);
  const assembly = app.synth(); // aspects (cdk-nag, guardrail) run at synth
  assert.ok(assembly.getStackByName('CanonApp'));
  const stack = app.node.findChild('CanonApp') as Stack;
  assert.deepEqual(Annotations.fromStack(stack).findError('*', Match.anyValue()), []);
});

test('default stack has the expected free-tier shape', () => {
  const stack = new AppStack(new App(), 'CanonApp', { config, lambdaDir });
  const t = Template.fromStack(stack);
  t.resourceCountIs('AWS::DynamoDB::Table', 1);
  t.hasResourceProperties('AWS::DynamoDB::Table', { ProvisionedThroughput: { ReadCapacityUnits: 5, WriteCapacityUnits: 5 } });
  t.resourceCountIs('AWS::Lambda::Function', 1);
  t.hasResourceProperties('AWS::Budgets::Budget', { Budget: { BudgetLimit: { Amount: 5, Unit: 'USD' } } });
  for (const paid of ['AWS::EC2::NatGateway', 'AWS::RDS::DBInstance', 'AWS::ElasticLoadBalancingV2::LoadBalancer', 'AWS::SecretsManager::Secret']) {
    t.resourceCountIs(paid, 0);
  }
  t.hasResourceProperties('AWS::S3::Bucket', { PublicAccessBlockConfiguration: Match.objectLike({ BlockPublicAcls: true, RestrictPublicBuckets: true }) });
});

function guarded(allowPaid: boolean) {
  const app = new App();
  const stack = new Stack(app, 'Bad');
  new CfnNatGateway(stack, 'Nat', { subnetId: 'subnet-1' });
  new CfnInstance(stack, 'Big', { instanceType: 'm5.large', imageId: 'ami-1' });
  new CfnInstance(stack, 'Small', { instanceType: 't3.micro', imageId: 'ami-1' });
  new Table(stack, 'OnDemand', { partitionKey: { name: 'pk', type: AttributeType.STRING }, billingMode: BillingMode.PAY_PER_REQUEST });
  new Table(stack, 'Big2', { partitionKey: { name: 'pk', type: AttributeType.STRING }, readCapacity: 30, writeCapacity: 5 });
  Aspects.of(app).add(new FreeTierGuard(allowPaid));
  app.synth();
  return Annotations.fromStack(stack);
}

test('guardrail errors on NAT, big instance, on-demand and over-allowance DynamoDB, but not t3.micro', () => {
  const a = guarded(false);
  const errors = a.findError('*', Match.stringLikeRegexp('Free-tier guardrail'));
  const ids = errors.map((e) => e.id);
  assert.ok(ids.some((i) => i.includes('Nat')), 'NAT flagged');
  assert.ok(ids.some((i) => i.includes('Big')), 'm5.large flagged');
  assert.ok(ids.some((i) => i.includes('OnDemand')), 'on-demand flagged');
  assert.ok(ids.some((i) => i.includes('Big2')), '30 RCU flagged');
  assert.ok(!ids.some((i) => i.includes('Small')), 't3.micro allowed');
});

test('allowPaid downgrades guardrail errors to warnings', () => {
  const a = guarded(true);
  assert.equal(a.findError('*', Match.stringLikeRegexp('Free-tier guardrail')).length, 0);
  assert.ok(a.findWarning('*', Match.stringLikeRegexp('Free-tier guardrail')).length >= 4);
});
