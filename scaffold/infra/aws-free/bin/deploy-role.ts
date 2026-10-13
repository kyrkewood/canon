import { fileURLToPath } from 'node:url';
import { App } from 'aws-cdk-lib';
import { loadConfigFile } from '../lib/config.js';
import { DeployRoleStack } from '../lib/deploy-role-stack.js';

// One-time, run by a person: npm run deploy-role -- -c githubRepo=owner/name -c oidcProviderArn=arn:aws:iam::<account>:oidc-provider/token.actions.githubusercontent.com
const config = loadConfigFile(fileURLToPath(new URL('../canon-infra.env', import.meta.url)));
const app = new App();
const githubRepo = String(app.node.tryGetContext('githubRepo') ?? '');
const oidcProviderArn = String(app.node.tryGetContext('oidcProviderArn') ?? '');
if (!/^[\w.-]+\/[\w.-]+$/.test(githubRepo)) throw new Error('pass -c githubRepo=owner/name');
if (!/^arn:aws[\w-]*:iam::\d{12}:oidc-provider\/token\.actions\.githubusercontent\.com$/.test(oidcProviderArn)) {
  throw new Error('pass -c oidcProviderArn=<ARN of the account\'s GitHub OIDC provider> (from the account baseline)');
}

new DeployRoleStack(app, `${config.appName}Deploy`, {
  githubRepo,
  githubEnvironment: config.envName,
  oidcProviderArn,
  env: { region: config.region, account: config.account },
});
