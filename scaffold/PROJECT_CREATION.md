# Project Creation Checklist

Use this when spinning up any product from the canon baseline.  
**A repo is not created until CI gates exist and can block merge.**

## 1. Bootstrap docs

- [ ] Copy into the new repo root (or submodule/subtree this baseline):
  - `AGENTS.md`
  - `PROJECT_RULES.md`
  - `SECURITY.md`
  - `ACCESSIBILITY.md`
  - `AI_INTEGRATION.md`
  - `ARCHITECTURE.md`
- [ ] Fill product-specific sections in `SECURITY.md`, `ACCESSIBILITY.md`, `AI_INTEGRATION.md`, and `ARCHITECTURE.md` (do not leave creation placeholders blank forever).
- [ ] In `SECURITY.md`, record: secrets manager choice, who owns key rotation, and any temporary CI exceptions.

## 2. Install CI (same PR as first commit of app skeleton)

Copy workflows from [`ci/`](ci/) into `.github/workflows/`:

| File | Required? | Action |
|------|-----------|--------|
| `secrets-scan.yml` | Always | Copy as-is |
| `dependency-review.yml` | Always (GitHub) | Copy as-is; enable Dependency graph |
| `sast.yml` | Always | Copy as-is; add project-specific Semgrep rules over time |
| `quality.yml` | Always | Fill in install / lint / typecheck / test for the stack |
| `accessibility.yml` | If UI | Enable and point at the real app URL or static build |

## 3. Wire stack commands

In `quality.yml` (and package scripts / Makefile):

- [ ] Install dependencies (locked)
- [ ] Lint
- [ ] Typecheck (typed languages)
- [ ] Unit tests
- [ ] (Optional) build

## 4. Branch protection

On the default branch, require:

- [ ] Secrets scan
- [ ] Dependency review (PRs)
- [ ] SAST
- [ ] Quality (lint/typecheck/test)
- [ ] Accessibility (if UI)

Do not allow bypasses for the implementing bot/user except break-glass accounts documented in `SECURITY.md`.

## 5. Secrets

- [ ] No `.env` with real secrets committed
- [ ] CI secrets only via GitHub Actions secrets / OIDC to a secrets manager
- [ ] Document rotation in `SECURITY.md`

## 6. Definition of done for “project created”

- [ ] Empty/smoke pipeline is green on `main`
- [ ] A deliberate failing check (e.g. planted secret in a branch) is blocked
- [ ] Docs + CI + protection are merged before feature delivery starts

## Specialist reviewers (optional, after CI)

Invoke on relevant PRs — they do not replace the gates above:

- Security / OWASP review when touching auth, data, or public APIs
- Accessibility review when touching UI
- Privacy review when touching logging, analytics, or retention
