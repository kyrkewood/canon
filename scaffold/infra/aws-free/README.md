# AWS free-tier starter (CDK, TypeScript)

Canon starter for `--infra=aws-free`. Not authoritative: check current AWS free-tier terms before relying on it (config last checked 2026-10-10, not verified live).

**Stack:** HTTP API -> Lambda (Node 24) -> DynamoDB (provisioned 5/5), private S3 bucket, SSM Parameter Store read access, monthly budget alert. No NAT gateway, load balancer or RDS.

**Config:** `canon-infra.env` (checked in, non-secret). Set `CANON_INFRA_BUDGET_EMAIL` before the first deploy; synth refuses the placeholder. Secrets go in SSM under `/CanonApp/<env>/`; list names, never values.

**Guardrails:** `cdk-nag` (AWS Solutions) plus `lib/free-tier-guard.ts`, which fails synth on resources that usually cost money. `CANON_INFRA_ALLOW_PAID=true` downgrades those errors to warnings.

```bash
npm ci
npm run typecheck && npm test
CANON_INFRA_PLACEHOLDER_OK=1 npx cdk synth   # offline; no AWS credentials needed
```

You run `cdk bootstrap`, `deploy` and `destroy` yourself with your own credentials. Canon does not. `destroy` removes the stack; the bootstrap bucket, repository and roles stay until you delete them. The assets bucket must be empty to be deleted.

CI wiring (PR check, OIDC deploy on merge, destroy workflow) is a later step; see `docs/features/infrastructure.md`.
