# Project Creation Checklist

**Preferred path:** run the apply script *or* paste the fetch & apply prompt in [`../ADOPT.md`](../ADOPT.md), then finish `CANON_NEXT_STEPS.md`.

```bash
# from a clone of this canon repo
./scaffold/apply.sh /path/to/your-project
# optional: --stack=node|python|none  --with-ui  --force  --credit
#            --github[=owner/name]  --public  --open-pr
```

Prompt-only (no terminal): open [`../ADOPT.md`](../ADOPT.md) and paste **Fetch & apply** into your coding agent.

A repo is not created until CI gates exist **and** the baseline is **merged via PR/MR to `main`**. Local commits alone are not done. GitHub is the default host; map the same steps on other forges.

Use this longer checklist when you need detail, or when applying by hand.

---

## 1. Bootstrap docs

- [ ] Prefer `./scaffold/apply.sh <target>` over hand-copying.
- [ ] Or copy into the new repo root: `AGENTS.md`, `CLAUDE.md`, `.cursor/rules/agents.mdc`, `PROJECT_RULES.md`, `SECURITY.md`, `ACCESSIBILITY.md`, `AI_INTEGRATION.md`, `ARCHITECTURE.md`, plus `docs/features/` (README + `_TEMPLATE.md`).
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

## 3. GitHub remote + baseline PR

- [ ] Git repo initialized
- [ ] GitHub remote `origin` exists (`gh repo create … --source=. --remote=origin` or `apply.sh --github`)
- [ ] Baseline committed on a branch (e.g. `chore/canon-baseline`), not treated as finished on local `main`
- [ ] PR opened to `main` (`gh pr create` or `apply.sh --open-pr`)
- [ ] PR merged after checks (do not auto-merge from Canon)

## 4. Wire stack commands

In `quality.yml` (and package scripts / Makefile):

- [ ] Install dependencies (locked)
- [ ] Lint
- [ ] Typecheck (typed languages)
- [ ] Unit tests
- [ ] (Optional) build
- [ ] **Local verify umbrella** documented and runnable (mirrors the gates above as closely as practical)
- [ ] **If public API:** OpenAPI (or equivalent) lint in CI — see [`AI_INTEGRATION.md`](../AI_INTEGRATION.md)
- [ ] **If MCP:** MCP package/tests included in CI / local verify
- [ ] **If UI:** component a11y tests in the unit/UI suite **and** `accessibility.yml` wired — see [`ACCESSIBILITY.md`](../ACCESSIBILITY.md)
- [ ] **If durable data / client state:** `SCHEMA.md` (or equivalent) + versioned contracts as needed
- [ ] Feature flags / env gates documented in `.env.example` (or equivalent)
- [ ] README (or `PLAN.md`) Done / Next / Later started; update as capabilities ship
- [ ] Fill product blanks in `SECURITY.md`, `AI_INTEGRATION.md`, `ACCESSIBILITY.md`, `ARCHITECTURE.md`
- [ ] Record delivery Route A (prefer Canon PR loop) or Route B (ask-before-commit) — `CANON_NEXT_STEPS` §7b / `AGENTS.md`
## 5. Branch protection (before feature PRs)

On the default branch, require:

- [ ] Secrets scan
- [ ] Dependency review (PRs)
- [ ] SAST
- [ ] Quality (lint/typecheck/test)
- [ ] Accessibility (if UI)

Do not allow bypasses for the implementing bot/user except break-glass accounts documented in `SECURITY.md`.

## 6. Secrets

- [ ] No `.env` with real secrets committed
- [ ] CI secrets only via GitHub Actions secrets / OIDC to a secrets manager
- [ ] Document rotation in `SECURITY.md`

## 7. Credit Canon (optional)

- [ ] README links back: `Baseline from [Canon](https://github.com/kyrkewood/canon).` (or `apply.sh --credit`)

## 8. Definition of done for “project created”

- [ ] GitHub remote exists
- [ ] Baseline landed via **PR merged to `main`**
- [ ] Branch protection enabled on `main` before feature PRs
- [ ] `CANON_NEXT_STEPS.md` completed and deleted
- [ ] Smoke pipeline green on `main` (after quality.yml is wired)
- [ ] A deliberate failing check (e.g. planted secret in a branch) is blocked
- [ ] Docs + CI + protection are in place before feature delivery starts

## Specialist reviewers (optional, after CI)

Invoke on relevant PRs — they do not replace the gates above:

- Security / OWASP review when touching auth, data, or public APIs
- Accessibility review when touching UI
- Privacy review when touching logging, analytics, or retention
