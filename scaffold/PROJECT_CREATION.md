# Project Creation Checklist

**Preferred path:** run the apply script *or* paste the fetch & apply prompt in [`../ADOPT.md`](../ADOPT.md), then finish `CANON_NEXT_STEPS.md`.

```bash
# from a clone of this canon repo
./scaffold/apply.sh /path/to/your-project
# optional: --stack=node|python|none  --with-ui  --force
```

Prompt-only (no terminal): open [`../ADOPT.md`](../ADOPT.md) and paste **Fetch & apply** into your coding agent.

A repo is not created until CI gates exist and can block merge. The script installs the files; you still finish the short next-steps list (toolchain, GitHub protection, product blanks).

Use this longer checklist when you need detail, or when applying by hand.

---

## 1. Bootstrap docs

- [ ] Prefer `./scaffold/apply.sh <target>` over hand-copying.
- [ ] Or copy into the new repo root: `AGENTS.md`, `PROJECT_RULES.md`, `SECURITY.md`, `ACCESSIBILITY.md`, `AI_INTEGRATION.md`, `ARCHITECTURE.md`.
- [ ] Fill product-specific sections in `SECURITY.md`, `ACCESSIBILITY.md`, `AI_INTEGRATION.md`, and `ARCHITECTURE.md`.
- [ ] In `SECURITY.md`, record: secrets manager choice, who owns key rotation, and any temporary CI exceptions.

## 2. Install CI (same PR as first commit of app skeleton)

Copied automatically by `apply.sh` into `.github/workflows/`:

| File | Required? | Action |
|------|-----------|--------|
| `secrets-scan.yml` | Always | Copy as-is |
| `dependency-review.yml` | Always (GitHub) | Copy as-is; enable Dependency graph |
| `sast.yml` | Always | Copy as-is; add project-specific Semgrep rules over time |
| `quality.yml` | Always | Prefills for node/python via apply.sh; otherwise fill by hand |
| `accessibility.yml` | If UI | Use `apply.sh --with-ui` and wire axe |

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

- [ ] `CANON_NEXT_STEPS.md` completed and deleted
- [ ] Empty/smoke pipeline is green on `main` (after quality.yml is wired)
- [ ] A deliberate failing check (e.g. planted secret in a branch) is blocked
- [ ] Docs + CI + protection are merged before feature delivery starts

## Specialist reviewers (optional, after CI)

Invoke on relevant PRs — they do not replace the gates above:

- Security / OWASP review when touching auth, data, or public APIs
- Accessibility review when touching UI
- Privacy review when touching logging, analytics, or retention
