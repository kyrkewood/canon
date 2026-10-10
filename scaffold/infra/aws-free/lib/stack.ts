import { CfnOutput, Duration, RemovalPolicy, Stack, StackProps } from 'aws-cdk-lib';
import { CfnStage, HttpApi } from 'aws-cdk-lib/aws-apigatewayv2';
import { HttpLambdaIntegration } from 'aws-cdk-lib/aws-apigatewayv2-integrations';
import { CfnBudget } from 'aws-cdk-lib/aws-budgets';
import { AttributeType, BillingMode, Table } from 'aws-cdk-lib/aws-dynamodb';
import { PolicyStatement, Role, ServicePrincipal } from 'aws-cdk-lib/aws-iam';
import { Code, Function as LambdaFunction, Runtime } from 'aws-cdk-lib/aws-lambda';
import { LogGroup, RetentionDays } from 'aws-cdk-lib/aws-logs';
import { BlockPublicAccess, Bucket, BucketEncryption } from 'aws-cdk-lib/aws-s3';
import { NagSuppressions } from 'cdk-nag';
import { Construct } from 'constructs';
import type { InfraConfig } from './config.js';

export interface AppStackProps extends StackProps {
  config: InfraConfig;
  /** Directory holding the Lambda code. */
  lambdaDir: string;
}

/**
 * Free-tier starter: HTTP API -> Lambda -> DynamoDB, a private S3 bucket,
 * SSM parameter read access, and a budget alert. No NAT, no load balancer, no RDS.
 */
export class AppStack extends Stack {
  constructor(scope: Construct, id: string, props: AppStackProps) {
    super(scope, id, props);
    const { config } = props;
    const ssmPath = `/${id}/${config.envName}`;

    // Provisioned 5/5 stays inside the always-free 25 RCU/WCU allowance.
    const table = new Table(this, 'Table', {
      partitionKey: { name: 'pk', type: AttributeType.STRING },
      sortKey: { name: 'sk', type: AttributeType.STRING },
      billingMode: BillingMode.PROVISIONED,
      readCapacity: 5,
      writeCapacity: 5,
      pointInTimeRecoverySpecification: { pointInTimeRecoveryEnabled: true },
      removalPolicy: RemovalPolicy.DESTROY,
    });

    const accessLogBucket = new Bucket(this, 'AccessLogs', {
      encryption: BucketEncryption.S3_MANAGED,
      blockPublicAccess: BlockPublicAccess.BLOCK_ALL,
      enforceSSL: true,
      removalPolicy: RemovalPolicy.DESTROY,
    });
    NagSuppressions.addResourceSuppressions(accessLogBucket, [
      { id: 'AwsSolutions-S1', reason: 'This is the access-log destination; it does not log to itself.' },
    ]);

    const bucket = new Bucket(this, 'Assets', {
      serverAccessLogsBucket: accessLogBucket,
      encryption: BucketEncryption.S3_MANAGED,
      blockPublicAccess: BlockPublicAccess.BLOCK_ALL,
      enforceSSL: true,
      removalPolicy: RemovalPolicy.DESTROY,
    });

    const handlerLogs = new LogGroup(this, 'HandlerLogs', { retention: RetentionDays.ONE_MONTH, removalPolicy: RemovalPolicy.DESTROY });
    const role = new Role(this, 'HandlerRole', { assumedBy: new ServicePrincipal('lambda.amazonaws.com') });
    role.addToPolicy(new PolicyStatement({ actions: ['logs:CreateLogStream', 'logs:PutLogEvents'], resources: [handlerLogs.logGroupArn] }));

    const fn = new LambdaFunction(this, 'Handler', {
      role,
      runtime: Runtime.NODEJS_24_X,
      handler: 'handler.handler',
      code: Code.fromAsset(props.lambdaDir),
      memorySize: 128,
      timeout: Duration.seconds(10),
      logGroup: handlerLogs,
      environment: { TABLE_NAME: table.tableName, BUCKET_NAME: bucket.bucketName, SSM_PATH: ssmPath },
    });
    table.grantReadWriteData(fn);
    fn.addToRolePolicy(
      new PolicyStatement({ actions: ['s3:GetObject', 's3:PutObject', 's3:DeleteObject'], resources: [bucket.arnForObjects('*')] }),
    );
    fn.addToRolePolicy(new PolicyStatement({ actions: ['s3:ListBucket'], resources: [bucket.bucketArn] }));
    fn.addToRolePolicy(
      new PolicyStatement({
        actions: ['ssm:GetParameter', 'ssm:GetParameters', 'ssm:GetParametersByPath'],
        resources: [`arn:${this.partition}:ssm:${this.region}:${this.account}:parameter${ssmPath}/*`],
      }),
    );

    const api = new HttpApi(this, 'Api', {
      defaultIntegration: new HttpLambdaIntegration('Integration', fn),
    });

    const accessLogs = new LogGroup(this, 'ApiAccessLogs', { retention: RetentionDays.ONE_MONTH, removalPolicy: RemovalPolicy.DESTROY });
    const stage = api.defaultStage?.node.defaultChild as CfnStage;
    stage.accessLogSettings = {
      destinationArn: accessLogs.logGroupArn,
      format: JSON.stringify({ requestId: '$context.requestId', ip: '$context.identity.sourceIp', route: '$context.routeKey', status: '$context.status' }),
    };

    new CfnBudget(this, 'Budget', {
      budget: {
        budgetType: 'COST',
        timeUnit: 'MONTHLY',
        budgetLimit: { amount: config.budgetUsd, unit: 'USD' },
      },
      notificationsWithSubscribers: [80, 100].map((threshold) => ({
        notification: { notificationType: 'ACTUAL', comparisonOperator: 'GREATER_THAN', threshold, thresholdType: 'PERCENTAGE' },
        subscribers: [{ subscriptionType: 'EMAIL', address: config.budgetEmail }],
      })),
    });

    NagSuppressions.addResourceSuppressionsByPath(
      this,
      [`/${id}/HandlerRole/DefaultPolicy/Resource`],
      [
        { id: 'AwsSolutions-IAM5', reason: 'Wildcards are limited to object keys in the assets bucket and the app SSM parameter prefix.', appliesTo: [{ regex: '/^Resource::.*/' }] },
      ],
    );
    NagSuppressions.addResourceSuppressions(api, [
      { id: 'AwsSolutions-APIG4', reason: 'Starter placeholder route is intentionally public. Add an authorizer before exposing real data.' },
    ], true);

    new CfnOutput(this, 'ApiUrl', { value: api.apiEndpoint });
  }
}
