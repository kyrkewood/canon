# CI scaffolds

**Prefer** [`../apply.sh`](../apply.sh) — it copies these into a project and prefills `quality.yml` for Node/Python.

Manual copy into `.github/workflows/` is fine if you cannot run the script.  
See [`../PROJECT_CREATION.md`](../PROJECT_CREATION.md) for the full checklist.

| Workflow | Blocks merge | Notes |
|----------|--------------|-------|
| `secrets-scan.yml` | Yes | Gitleaks; stack-agnostic |
| `dependency-review.yml` | Yes (PRs) | Needs GitHub Dependency graph |
| `sast.yml` | Yes | Semgrep; extend with app rules |
| `quality.yml` | Yes | Prefill via apply.sh, or replace placeholders |
| `accessibility.yml` | Yes if UI | Use `apply.sh --with-ui` |

Prompt-only reviews are not a substitute for these jobs.
