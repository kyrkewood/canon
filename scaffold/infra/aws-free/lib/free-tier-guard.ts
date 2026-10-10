import { Annotations, CfnResource, IAspect } from 'aws-cdk-lib';
import { CfnInstance } from 'aws-cdk-lib/aws-ec2';
import { CfnTable } from 'aws-cdk-lib/aws-dynamodb';
import { CfnRepository } from 'aws-cdk-lib/aws-ecr';
import { IConstruct } from 'constructs';

/** Resource types that routinely cost money outside the free tier. */
const PAID_TYPES = new Set([
  'AWS::EC2::NatGateway',
  'AWS::ElasticLoadBalancingV2::LoadBalancer',
  'AWS::ElasticLoadBalancing::LoadBalancer',
  'AWS::RDS::DBInstance',
  'AWS::RDS::DBCluster',
  'AWS::OpenSearchService::Domain',
  'AWS::Elasticsearch::Domain',
  'AWS::SecretsManager::Secret',
  'AWS::EC2::VPCEndpoint',
  'AWS::ElastiCache::CacheCluster',
  'AWS::ElastiCache::ReplicationGroup',
  'AWS::MSK::Cluster',
  'AWS::Route53::HostedZone',
  'AWS::WAFv2::WebACL',
  // Customer-managed keys bill about $1/month each plus requests.
  'AWS::KMS::Key',
  // Public IPv4 addresses are billed hourly, attached or not.
  'AWS::EC2::EIP',
  // Fargate tasks have no free tier.
  'AWS::ECS::Service',
  // Threat detection and config recording bill per event or item.
  'AWS::GuardDuty::Detector',
  'AWS::Config::ConfigurationRecorder',
]);
const FREE_INSTANCE = /^t[234]g?\.(micro)$/;
/** DynamoDB always-free allowance is 25 RCU + 25 WCU provisioned across tables. */
const DDB_FREE_UNITS = 25;

export class FreeTierGuard implements IAspect {
  private ddbRead = 0;
  private ddbWrite = 0;
  private readonly trails = new Set<string>();
  constructor(private readonly allowPaid: boolean) {}

  visit(node: IConstruct): void {
    if (!CfnResource.isCfnResource(node)) return;
    const type = node.cfnResourceType;

    if (PAID_TYPES.has(type)) this.flag(node, `${type} is not free-tier safe`);

    if (node instanceof CfnInstance && !FREE_INSTANCE.test(node.instanceType ?? '')) {
      this.flag(node, `EC2 instance type ${node.instanceType} is outside free-tier micro sizes`);
    }

    // The first management-event trail is free; later ones bill per event.
    if (type === 'AWS::CloudTrail::Trail') {
      // Aspects can visit a node more than once, so count distinct nodes.
      this.trails.add(node.node.path);
      if (this.trails.size > 1 && [...this.trails][0] !== node.node.path) this.flag(node, 'additional CloudTrail trails are not free');
    }

    if (node instanceof CfnRepository && !node.lifecyclePolicy) {
      this.flag(node, 'ECR repository has no lifecycle policy; stored images bill by the GB-month');
    }

    if (node instanceof CfnTable) {
      if (node.billingMode === 'PAY_PER_REQUEST') {
        this.flag(node, 'DynamoDB on-demand billing is outside the always-free provisioned allowance');
      }
      const tp = node.provisionedThroughput as CfnTable.ProvisionedThroughputProperty | undefined;
      this.ddbRead += tp?.readCapacityUnits ?? 0;
      this.ddbWrite += tp?.writeCapacityUnits ?? 0;
      if (this.ddbRead > DDB_FREE_UNITS || this.ddbWrite > DDB_FREE_UNITS) {
        this.flag(node, `DynamoDB provisioned capacity exceeds ${DDB_FREE_UNITS} RCU/WCU always-free allowance`);
      }
    }
  }

  private flag(node: IConstruct, message: string): void {
    const text = `Free-tier guardrail: ${message}. Set CANON_INFRA_ALLOW_PAID=true only if you accept the cost.`;
    if (this.allowPaid) Annotations.of(node).addWarning(text);
    else Annotations.of(node).addError(text);
  }
}
