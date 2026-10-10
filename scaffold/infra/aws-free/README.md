# AWS free-tier starter (CDK, TypeScript)

Canon starter for `--infra=aws-free`. Not authoritative: check current AWS free-tier terms before relying on it (config last checked 2026-10-10, not verified live).

**Stack:** HTTP API -> Lambda (Node 24) -> DynamoDB (provisioned 5/5), private S3 bucket, SSM Parameter Store read access, monthly budget alert. No NAT gateway, load balancer or RDS.

**Config:** `canon-infra.env` (checked in, non-secret). Set `CANON_INFRA_BUDGET_EMAIL` before the first deploy; synth refuses the placeholder. Secrets go in SSM under `/<app name>/<env>/` (`CanonApp` by default; set `CANON_INFRA_APP_NAME` so several apps can share an account); list names, never values.

**Account pinning:** set `CANON_INFRA_ACCOUNT_ID` so a deploy with the wrong credentials fails instead of landing in another account.

**Cost notes:** the table has point-in-time recovery on (a small charge beyond the free tier, and `cdk-nag` expects it); the API stage is throttled to 10 req/s (burst 20); the `prod` table is retained on `destroy`, so delete it by hand; Lambda runs on arm64; the assets bucket has no access-log bucket (`AwsSolutions-S1` is suppressed with a reason).

**Accounts:** each AWS account needs its own `cdk bootstrap` and deploy role. Keep account-level baseline (bootstrap, OIDC roles, any read-only access) in a separate account-baseline repo, not here.

**Guardrails:** `cdk-nag` (AWS Solutions) plus `lib/free-tier-guard.ts`, which fails synth on resources that usually cost money. `CANON_INFRA_ALLOW_PAID=true` downgrades those errors to warnings.

```bash
npm ci
npm run typecheck && npm test
CANON_INFRA_PLACEHOLDER_OK=1 npx cdk synth   # offline; no AWS credentials needed
```

You run `cdk bootstrap`, `deploy` and `destroy` yourself with your own credentials. Canon does not. `destroy` removes the stack (except the retained `prod` table); the bootstrap bucket, repository and roles stay until you delete them. The assets bucket must be empty to be deleted.

**CI (installed by `apply.sh --infra=aws-free`):** `infra-synth.yml` (PR + `main`, no credentials), `infra-deploy.yml` (OIDC deploy on merge, skipped until the repo variable `DEPLOY_ENABLED` is `true`) and an `infra` job in `quality.yml` (lint, typecheck, tests). The destroy workflow is a later step; see `docs/features/infrastructure.md`.

**One-time OIDC role** (`lib/github-oidc-stack.ts`): set `CANON_INFRA_GITHUB_REPO`, then run `npm run deploy:oidc` once by hand with admin credentials. The pipeline cannot create its own first role. The role trusts exactly `repo:<owner>/<repo>:environment:<env>` (audience `sts.amazonaws.com`, never a wildcard) and may only `sts:AssumeRole` on the four `cdk-<qualifier>-{deploy,file-publishing,image-publishing,lookup}-role-<account>-<region>` bootstrap roles. An account holds only one GitHub OIDC provider; if it already has one, set `CANON_INFRA_OIDC_PROVIDER_ARN` to reuse it. Then follow section 6b of `CANON_NEXT_STEPS.md`.
