# CI scaffolds

**Prefer** [`../apply.sh`](../apply.sh) — it copies these into a project and prefills `quality.yml` for Node/Python.

Manual copy into `.github/workflows/` is fine if you cannot run the script.  
See [`../PROJECT_CREATION.md`](../PROJECT_CREATION.md) for the full checklist.

| Workflow | Blocks merge | Notes |
|----------|--------------|-------|
| `secrets-scan.yml` | Yes | Gitleaks; stack-agnostic |
| `dependency-review.yml` | Yes (PRs) | Needs GitHub Dependency graph; high+ fails |
| `sast.yml` | Yes | Semgrep OWASP Top 10 + security-audit; SARIF upload |
| `no-static-aws-keys.yml` | Yes | Fails workflows naming AWS access keys, secret keys or session tokens; use OIDC |
| `quality.yml` | Yes | Prefill via apply.sh, or replace placeholders |
| `accessibility.yml` | Yes if UI | Use `apply.sh --with-ui`; AA automated floor |
| `deploy.yml` | No | **Opt-in**, for `--infra=aws-free`: deploy on merge via OIDC; needs `AWS_DEPLOY_ROLE_ARN` on the GitHub environment |
| `dast.yml` | Yes once enabled | **Opt-in** — copy manually; needs running URL (`ZAP_TARGET_URL`) |

Failures should cite rule IDs (Semgrep/axe logs, SARIF). Waivers: see [`SECURITY.md`](../../SECURITY.md) — no silent `continue-on-error` on required gates.

Prompt-only reviews are not a substitute for these jobs.
