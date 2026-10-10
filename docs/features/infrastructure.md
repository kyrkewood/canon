# Feature: Default infrastructure (AWS free tier)

## Purpose

Let an adopter pick an infrastructure preference when applying Canon and get a working, reviewed, deploy-on-merge setup sized for the AWS free tier. The default is AWS free tier with CDK (TypeScript). The goal is a safe starting point, not a production platform.

## How it should work

`apply.sh --infra=aws-free|none` (default `none`; `ADOPT.md` tells agents to ask). Choosing `aws-free` copies a self-contained `infra/` directory, `infra-synth.yml` and `infra-deploy.yml`, adds an `infra` job to `quality.yml`, and records the choice in `infra/canon-infra.env`. With `none`, nothing infra-related is installed. `infra/canon-infra.env` is adopter-owned: re-running with `--force` never overwrites it.

**Stack (fixed defaults):** Lambda + API Gateway, DynamoDB, S3, SSM Parameter Store for secrets (not Secrets Manager), an AWS Budgets alert. No NAT gateway, no load balancer, no RDS.

**Config:** `infra/canon-infra.env` is checked in and non-secret. The CDK app reads it at synth time.

| Variable | Default | Notes |
|----------|---------|-------|
| `CANON_INFRA_REGION` | `us-east-1` | |
| `CANON_INFRA_DEPLOY` | `merge` | `merge` \| `manual` \| `tag` \| `none` |
| `CANON_INFRA_BUDGET_USD` | `5` | Budget alert threshold |
| `CANON_INFRA_ENV_NAME` | `prod` | Single environment only |
| `CANON_INFRA_ACCOUNT_ID` | unset | Optional. Pins `env.account` so wrong credentials fail |
| `CANON_INFRA_APP_NAME` | `CanonApp` | Optional. Stack id and SSM path root |
| `CANON_INFRA_GITHUB_REPO` | unset | `owner/name`, exact. Needed only for the one-time OIDC stack |
| `CANON_INFRA_OIDC_PROVIDER_ARN` | unset | Optional. Reuse the account's existing GitHub OIDC provider |
| `CANON_INFRA_ALLOW_PAID` | unset | Explicit escape hatch from the free-tier guardrail |

Database and compute are not selectable in v1; changing them means editing the CDK code.

**Secrets** live in SSM Parameter Store. The config file lists parameter names, never values. A test fails if a value looks like a credential.

**Deploy (default `merge`):**

- Pull request and push to `main` (`infra-synth.yml`): `cdk synth` + `cdk-nag` (AWS Solutions pack) + a custom free-tier rule (fails on NAT gateways, non-micro instances, RDS, load balancers, KMS keys, EIPs unless `CANON_INFRA_ALLOW_PAID`). No AWS credentials and no `id-token` permission; fork PRs never get any. Lint, typecheck and tests run in an `infra` job in `quality.yml`.
- Merge to `main`, or `workflow_dispatch` (`infra-deploy.yml`): `cdk deploy` via GitHub OIDC (no long-lived keys, `aws-actions/configure-aws-credentials`). `id-token: write` is set on the job only. The job runs in a GitHub `environment` that holds `AWS_DEPLOY_ROLE_ARN`, so required reviewers can be added; the role trusts exactly `repo:<owner>/<repo>:environment:<env>` and may only assume the four CDK bootstrap roles (`lib/github-oidc-stack.ts`); broad permissions sit in the CloudFormation execution role. The job is gated by the repo variable `DEPLOY_ENABLED == 'true'`, so a fresh adopter's first merge does not fail before OIDC exists. Deploys run serially in one `concurrency` group (`deploy`) and are never cancelled mid-flight.
- Other modes ship as separate workflow templates (`deploy-manual.yml`, `deploy-on-tag.yml`); `apply.sh` copies the one selected.

**Teardown:** `npm run destroy` locally, and a `workflow_dispatch` destroy workflow that needs a typed confirmation and the same GitHub environment.

**Human steps** (listed in `CANON_NEXT_STEPS`, never run by Canon):

1. Edit `infra/canon-infra.env` (budget email, region, account id, GitHub repo).
2. `cdk bootstrap` with the adopter's own credentials.
3. Deploy the one-time OIDC role stack by hand (`npm run deploy:oidc`, admin credentials: the pipeline cannot create its own first role). An account holds one GitHub OIDC provider; reuse an existing one via `CANON_INFRA_OIDC_PROVIDER_ARN`.
4. Create the GitHub environment (name = `CANON_INFRA_ENV_NAME`), with required reviewers on any account that controls IAM, and set `AWS_DEPLOY_ROLE_ARN` on it.
5. Protect `main` and require Infra synth and Quality.
6. Set the repo variable `DEPLOY_ENABLED=true`, last.
7. Confirm the new `infra/` dependencies (`aws-cdk-lib`, `constructs`, `cdk-nag`, `eslint`, `typescript-eslint`). Choosing `--infra=aws-free` counts as approval for these, listed as one checklist line.

## Non-goals

- No other providers shipped. Others are a documented extension point: IaC as code, reviewed, deployed via OIDC. Add one only when someone runs and tests it.
- No second IaC tool; no Terraform/OpenTofu/Pulumi.
- Canon never runs `cdk bootstrap`, `deploy` or `destroy`, and sessions get no AWS credentials by default. Verification is offline (`synth`, `cdk-nag`). The only exception is the read-only role below.
- No multi-environment (staging/prod) default.
- No RDS, containers or custom networking in v1.
- No claim that the stack is "free". Cost claims are best-effort.

## Exception: read-only session role

Default is no credentials. A human may grant a session one AWS role, only when offline checks cannot answer the question (for example, inspecting what is actually deployed, or cost and budget state) and only when all of these hold:

- The role is read-only and metadata-only: describe, list and get calls on resource configuration, CloudFormation, Budgets and Cost Explorer. No data-plane reads (S3 objects, DynamoDB items, SSM parameter values, logs), no `kms:Decrypt`, no write actions of any kind.
- A person created and granted it for that environment or task. The agent never requests, widens or creates credentials, and never assumes a role it was not given.
- It is short-lived (an assumed role with a session duration, or a revocable role), scoped to one account, and defined outside this repo (the account-baseline repo), so its policy is reviewed separately.
- Its use is declared in the session or PR, and results show resource names and states, never secret values.
- Deploy, bootstrap, destroy and any mutating call stay human-only, whatever the role allows. If a call would write, stop and hand it to the human.

Canon ships no such role; this rule only permits one. If the role grants more than read-only metadata, the exception does not apply and the default rule stands.

## Edge cases & failure modes

- **Free-tier terms change.** AWS reworked its free tier in 2025 (credits-based plans for new accounts, to be verified). Files carry a "last checked" date and say "verify against current AWS terms". No CI job tracks pricing.
- **Deploy happens after merge**, so a failed deploy leaves `main` ahead of production. The failure must show as a failing run.
- **Cancelling a CloudFormation update mid-way** can strand a stack in `UPDATE_ROLLBACK_FAILED`; hence no cancel-in-progress.
- **Over-broad OIDC trust** (`repo:owner/name:*`) would let any branch or PR deploy. Trust is scoped to the environment/`main`.
- **Config with credentials-looking values** fails the secrets test.
- **Overriding the guardrail** with `CANON_INFRA_ALLOW_PAID` is allowed but must be visible in review.
- **Bootstrap costs** a small S3 bucket, ECR repo and roles that outlive the stack; teardown docs say so.
- **Example rot.** CI synths and scans the shipped example; `apply.sh` smoke asserts the copied files.

## Decisions

| Date | Decision | Why | Revisit when |
|------|----------|-----|--------------|
| 2026-10-10 | Ship conventions plus an opt-in example, amending the "no stack-specific implementations" line in `product-conventions.md` | Adopters need something runnable; the example is opt-in and labelled non-authoritative | If the example becomes a maintenance burden |
| 2026-10-10 | One tool, one provider: AWS + CDK (TypeScript) | Maintainer prefers CDK; one tool avoids a user-facing tool choice; GCP cannot be judged or tested by the maintainer | When someone runs and tests a second provider |
| 2026-10-10 | DynamoDB + Lambda fixed defaults | Cheapest, fastest, lowest surprise-bill risk | If SQL demand is common |
| 2026-10-10 | Deploy on merge via GitHub OIDC, environment-scoped | No long-lived keys; matches `SECURITY.md`; approvals can be added later | If a staging environment is needed |
| 2026-10-10 | Few config knobs (region, deploy mode, budget, env name) | Each knob is an untested combination that can break the free-tier guarantee | If adopters repeatedly edit the same code |
| 2026-10-10 | Canon and its sessions hold no AWS credentials by default | Verification is offline; humans apply | Never expected |
| 2026-10-10 | Allow one human-granted, read-only, metadata-only role as a strict exception | Some questions (what is deployed, what it costs) cannot be answered offline; the role is defined outside this repo and never writes | If a session ever needs more than metadata reads |
| 2026-10-10 | Default is opt-in (`none` remains first class) | Existing adopters see no change; minimal-change rule | — |
| 2026-10-10 | Deploy job gated by repo variable `DEPLOY_ENABLED=='true'`, set last | The first merge after apply must not fail red before OIDC exists | If a setup check can replace the manual switch |
| 2026-10-10 | `id-token: write` on the deploy job only; `contents: read` at workflow level | Least privilege: no other job or fork can mint an OIDC token | — |
| 2026-10-10 | OIDC role stack ships in `infra/` but is deployed by hand, outside the pipeline's app | A pipeline cannot create its own first role; Canon never runs deploy | If account-baseline tooling replaces it |
| 2026-10-10 | Role trust is exact `repo:<owner>/<repo>:environment:<env>`; stack and config reject wildcards | A wildcard would let any branch or PR deploy | Never expected |
| 2026-10-10 | Existing GitHub OIDC provider reused through `CANON_INFRA_OIDC_PROVIDER_ARN` | An account can hold only one; a duplicate create fails | If adopters rarely share accounts |
| 2026-10-10 | Infra lint, typecheck and tests run as an `infra` job inside `quality.yml` | Root `package.json` steps never see `infra/`; Quality stays the one required check | If infra needs its own required check |
| 2026-10-10 | Deploy runs only for changes under `infra/` (plus `workflow_dispatch`) | Avoids a reviewer approval on every unrelated merge | If infra depends on files outside `infra/` |
| 2026-10-10 | `infra/canon-infra.env` is never overwritten by `apply.sh`, even with `--force` | It holds the adopter's account, region and email | — |
| 2026-10-10 | Infra synth tolerates the placeholder budget email until `DEPLOY_ENABLED` is true | The baseline PR stays green; once deploys are on, the placeholder fails before merge | — |

## Open questions

- Exact `apply.sh` prompt wording and how `ADOPT.md` instructs agents to ask.
- Whether the custom free-tier rule lives in the example or ships as a reusable package.
- Whether a permissions boundary on the CloudFormation execution role is in the first slice or a follow-up.
- Current AWS free-tier terms to quote in the file headers.

## Thin-slice order

1. This doc, plus the `product-conventions.md` non-goals amendment and a `SECURITY.md`/`ARCHITECTURE.md` link.
2. `infra/` CDK example (stack + config reader + guardrail rule) with synth and `cdk-nag` in CI.
3. PR check and merge-deploy workflows, OIDC role stack, `CANON_NEXT_STEPS` entries. (Done.)
4. `apply.sh --infra`, smoke test, `ADOPT.md`. (Done; the interactive prompt is not built.)
5. Destroy workflow and alternate deploy-mode templates.
