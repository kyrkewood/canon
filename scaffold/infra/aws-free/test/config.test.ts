import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { test } from 'node:test';
import { fileURLToPath } from 'node:url';
import { loadConfig, parseEnvFile } from '../lib/config.js';

const good = {
  CANON_INFRA_PROVIDER: 'aws-free',
  CANON_INFRA_REGION: 'us-east-1',
  CANON_INFRA_DEPLOY: 'merge',
  CANON_INFRA_BUDGET_USD: '5',
  CANON_INFRA_BUDGET_EMAIL: 'me@corp.test',
  CANON_INFRA_ENV_NAME: 'prod',
};

test('shipped canon-infra.env parses (placeholder email allowed only when asked)', () => {
  const file = parseEnvFile(readFileSync(fileURLToPath(new URL('../canon-infra.env', import.meta.url)), 'utf8'));
  assert.throws(() => loadConfig(file, false), /placeholder/);
  assert.equal(loadConfig(file, true).deploy, 'merge');
});

test('accepts a valid config', () => {
  assert.deepEqual(loadConfig(good), {
    region: 'us-east-1', account: undefined, appName: 'CanonApp', deploy: 'merge', budgetUsd: 5, budgetEmail: 'me@corp.test', envName: 'prod', allowPaid: false, githubRepo: undefined, oidcProviderArn: undefined,
  });
});

for (const [name, patch, re] of [
  ['bad region', { CANON_INFRA_REGION: 'moon' }, /REGION/],
  ['bad deploy mode', { CANON_INFRA_DEPLOY: 'yolo' }, /DEPLOY/],
  ['zero budget', { CANON_INFRA_BUDGET_USD: '0' }, /BUDGET_USD/],
  ['bad email', { CANON_INFRA_BUDGET_EMAIL: 'nope' }, /EMAIL/],
  ['bad env name', { CANON_INFRA_ENV_NAME: 'Prod!' }, /ENV_NAME/],
  ['bad account id', { CANON_INFRA_ACCOUNT_ID: '123' }, /ACCOUNT_ID/],
  ['bad app name', { CANON_INFRA_APP_NAME: 'bad name' }, /APP_NAME/],
  ['wrong provider', { CANON_INFRA_PROVIDER: 'gcp' }, /PROVIDER/],
] as const) {
  test(`rejects ${name}`, () => assert.throws(() => loadConfig({ ...good, ...patch }), re));
}

test('rejects secret-looking keys and credential-looking values', () => {
  assert.throws(() => loadConfig({ ...good, CANON_INFRA_API_KEY: 'abc' }), /secret/);
  assert.throws(() => loadConfig({ ...good, CANON_INFRA_NOTE: 'AKIAABCDEFGHIJKLMNOP' }), /credential/);
});

test('allowPaid only when exactly "true"', () => {
  assert.equal(loadConfig({ ...good, CANON_INFRA_ALLOW_PAID: 'true' }).allowPaid, true);
  assert.equal(loadConfig({ ...good, CANON_INFRA_ALLOW_PAID: 'yes' }).allowPaid, false);
});

test('accepts an account id and app name', () => {
  const cfg = loadConfig({ ...good, CANON_INFRA_ACCOUNT_ID: '123456789012', CANON_INFRA_APP_NAME: 'Shop' });
  assert.equal(cfg.account, '123456789012');
  assert.equal(cfg.appName, 'Shop');
});

test('accepts a GitHub repo and an existing OIDC provider arn', () => {
  const arn = 'arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com';
  const cfg = loadConfig({ ...good, CANON_INFRA_GITHUB_REPO: 'me/app', CANON_INFRA_OIDC_PROVIDER_ARN: arn });
  assert.equal(cfg.githubRepo, 'me/app');
  assert.equal(cfg.oidcProviderArn, arn);
});

for (const repo of ['me/*', '*', 'me', 'me/app:*']) {
  test(`rejects GitHub repo ${repo}`, () => assert.throws(() => loadConfig({ ...good, CANON_INFRA_GITHUB_REPO: repo }), /GITHUB_REPO/));
}

test('rejects an OIDC provider arn that is not the GitHub provider', () => {
  assert.throws(() => loadConfig({ ...good, CANON_INFRA_OIDC_PROVIDER_ARN: 'arn:aws:iam::123456789012:oidc-provider/evil.example.com' }), /OIDC_PROVIDER_ARN/);
});
