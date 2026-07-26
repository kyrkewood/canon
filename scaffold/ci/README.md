# CI scaffolds

Copy these into a new product’s `.github/workflows/` during project creation.  
See [`PROJECT_CREATION.md`](PROJECT_CREATION.md) for the full checklist.

| Workflow | Blocks merge | Notes |
|----------|--------------|-------|
| `secrets-scan.yml` | Yes | Gitleaks; stack-agnostic |
| `dependency-review.yml` | Yes (PRs) | Needs GitHub Dependency graph |
| `sast.yml` | Yes | Semgrep; extend with app rules |
| `quality.yml` | Yes | **Must** replace placeholders with real commands |
| `accessibility.yml` | Yes if UI | Disabled by default path filter until UI exists |

Prompt-only reviews are not a substitute for these jobs.
