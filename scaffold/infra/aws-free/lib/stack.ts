import { CfnOutput, Duration, RemovalPolicy, Stack, StackProps } from 'aws-cdk-lib';
import { CfnStage, HttpApi } from 'aws-cdk-lib/aws-apigatewayv2';
import { HttpLambdaIntegration } from 'aws-cdk-lib/aws-apigatewayv2-integrations';
import { CfnBudget } from 'aws-cdk-lib/aws-budgets';
import { AttributeType, BillingMode, Table } from 'aws-cdk-lib/aws-dynamodb';
import { PolicyStatement, Role, ServicePrincipal } from 'aws-cdk-lib/aws-iam';
import { Architecture, Code, Function as LambdaFunction, Runtime } from 'aws-cdk-lib/aws-lambda';
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
    const isProd = config.envName === 'prod';

    // Provisioned 5/5 stays inside the always-free 25 RCU/WCU allowance.
    const table = new Table(this, 'Table', {
      partitionKey: { name: 'pk', type: AttributeType.STRING },
      sortKey: { name: 'sk', type: AttributeType.STRING },
      billingMode: BillingMode.PROVISIONED,
      readCapacity: 5,
      writeCapacity: 5,
      pointInTimeRecoverySpecification: { pointInTimeRecoveryEnabled: true },
      // A destroy or failed replacement must not delete production data.
      removalPolicy: isProd ? RemovalPolicy.RETAIN : RemovalPolicy.DESTROY,
    });

    const bucket = new Bucket(this, 'Assets', {
      encryption: BucketEncryption.S3_MANAGED,
      blockPublicAccess: BlockPublicAccess.BLOCK_ALL,
      enforceSSL: true,
      removalPolicy: RemovalPolicy.DESTROY,
    });
    NagSuppressions.addResourceSuppressions(bucket, [
      { id: 'AwsSolutions-S1', reason: 'Starter: a second bucket only to hold access logs adds storage cost. Enable server access logs when the bucket holds real data.' },
    ]);

    const handlerLogs = new LogGroup(this, 'HandlerLogs', { retention: RetentionDays.ONE_MONTH, removalPolicy: RemovalPolicy.DESTROY });
    const role = new Role(this, 'HandlerRole', { assumedBy: new ServicePrincipal('lambda.amazonaws.com') });
    role.addToPolicy(new PolicyStatement({ actions: ['logs:CreateLogStream', 'logs:PutLogEvents'], resources: [handlerLogs.logGroupArn] }));

    const fn = new LambdaFunction(this, 'Handler', {
      role,
      runtime: Runtime.NODEJS_24_X,
      architecture: Architecture.ARM_64,
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
    // Caps request rate so a traffic spike cannot run up Lambda and DynamoDB cost.
    stage.defaultRouteSettings = { throttlingRateLimit: 10, throttlingBurstLimit: 20 };
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
