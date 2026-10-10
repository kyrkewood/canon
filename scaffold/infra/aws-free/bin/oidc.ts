import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { App } from 'aws-cdk-lib';
import { loadConfig, parseEnvFile } from '../lib/config.js';
import { GithubOidcStack } from '../lib/github-oidc-stack.js';

// Run by hand with admin credentials: `npm run deploy:oidc`. Not part of the pipeline's app.
// The budget email is not used here, so the placeholder is allowed.
const config = loadConfig(parseEnvFile(readFileSync(fileURLToPath(new URL('../canon-infra.env', import.meta.url)), 'utf8')), true);
if (!config.githubRepo) throw new Error('Set CANON_INFRA_GITHUB_REPO (owner/name) in canon-infra.env before deploying the OIDC stack');

const app = new App();
new GithubOidcStack(app, `${config.appName}-GithubOidc`, {
  env: { region: config.region, account: config.account },
  githubRepo: config.githubRepo,
  githubEnvironment: config.envName,
  existingProviderArn: config.oidcProviderArn,
});
app.synth();
