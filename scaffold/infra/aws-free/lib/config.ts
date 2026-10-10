import { readFileSync } from 'node:fs';

export const DEPLOY_MODES = ['merge', 'manual', 'tag', 'none'] as const;
export type DeployMode = (typeof DEPLOY_MODES)[number];

export interface InfraConfig {
  region: string;
  deploy: DeployMode;
  budgetUsd: number;
  budgetEmail: string;
  envName: string;
  allowPaid: boolean;
}

const CREDENTIAL_VALUE = /AKIA[0-9A-Z]{16}|ASIA[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY-----|ghp_[A-Za-z0-9]{20,}/;
const SECRET_KEY_NAME = /(SECRET|TOKEN|PASSWORD|PASSWD|API_?KEY|PRIVATE)/i;

export function parseEnvFile(text: string): Record<string, string> {
  const out: Record<string, string> = {};
  for (const raw of text.split('\n')) {
    const line = raw.trim();
    if (!line || line.startsWith('#')) continue;
    const eq = line.indexOf('=');
    if (eq < 1) throw new Error(`canon-infra.env: malformed line: ${line}`);
    out[line.slice(0, eq).trim()] = line.slice(eq + 1).trim();
  }
  return out;
}

/** Throws if the file looks like it holds a credential. Config is checked in, so it must stay non-secret. */
export function assertNoSecrets(values: Record<string, string>): void {
  for (const [key, value] of Object.entries(values)) {
    if (SECRET_KEY_NAME.test(key) && value) {
      throw new Error(`canon-infra.env: ${key} looks like a secret; store it in SSM Parameter Store and list only its name`);
    }
    if (CREDENTIAL_VALUE.test(value)) {
      throw new Error(`canon-infra.env: value of ${key} looks like a credential`);
    }
  }
}

export function loadConfig(values: Record<string, string>, placeholderOk = process.env.CANON_INFRA_PLACEHOLDER_OK === '1'): InfraConfig {
  assertNoSecrets(values);

  if (values.CANON_INFRA_PROVIDER !== 'aws-free') {
    throw new Error(`CANON_INFRA_PROVIDER must be aws-free (got ${values.CANON_INFRA_PROVIDER ?? 'unset'})`);
  }
  const region = values.CANON_INFRA_REGION ?? '';
  if (!/^[a-z]{2}(-[a-z]+)+-\d$/.test(region)) throw new Error(`CANON_INFRA_REGION invalid: ${region}`);

  const deploy = values.CANON_INFRA_DEPLOY as DeployMode;
  if (!DEPLOY_MODES.includes(deploy)) throw new Error(`CANON_INFRA_DEPLOY must be one of ${DEPLOY_MODES.join('|')}`);

  const budgetUsd = Number(values.CANON_INFRA_BUDGET_USD);
  if (!Number.isFinite(budgetUsd) || budgetUsd <= 0) throw new Error('CANON_INFRA_BUDGET_USD must be a positive number');

  const budgetEmail = values.CANON_INFRA_BUDGET_EMAIL ?? '';
  if (!/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(budgetEmail)) throw new Error('CANON_INFRA_BUDGET_EMAIL must be an email address');
  if (!placeholderOk && /^CHANGE_ME@|@example\.(com|invalid)$/i.test(budgetEmail)) {
    throw new Error('CANON_INFRA_BUDGET_EMAIL is still the placeholder; budget alerts would go nowhere');
  }

  const envName = values.CANON_INFRA_ENV_NAME ?? '';
  if (!/^[a-z][a-z0-9-]{0,19}$/.test(envName)) throw new Error('CANON_INFRA_ENV_NAME must be lowercase letters, digits or hyphens (max 20)');

  return { region, deploy, budgetUsd, budgetEmail, envName, allowPaid: values.CANON_INFRA_ALLOW_PAID === 'true' };
}

export function loadConfigFile(path: string): InfraConfig {
  return loadConfig(parseEnvFile(readFileSync(path, 'utf8')));
}
