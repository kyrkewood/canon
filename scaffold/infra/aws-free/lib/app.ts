import { App, Aspects } from 'aws-cdk-lib';
import { AwsSolutionsChecks } from 'cdk-nag';
import type { InfraConfig } from './config.js';
import { FreeTierGuard } from './free-tier-guard.js';
import { AppStack } from './stack.js';

export function buildApp(config: InfraConfig, lambdaDir: string): App {
  const app = new App();
  new AppStack(app, config.appName, { config, lambdaDir, env: { region: config.region, account: config.account } });
  Aspects.of(app).add(new AwsSolutionsChecks({ verbose: true }));
  Aspects.of(app).add(new FreeTierGuard(config.allowPaid));
  return app;
}
