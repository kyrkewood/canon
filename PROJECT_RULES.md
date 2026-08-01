# Project Engineering Rules (v1)

Portable baseline for products scaffolded from this repository.  
This file is the **index**: principles, always-on engineering norms, and pointers to domain rulebooks.

Detailed standards live in:

| Doc | Covers |
|-----|--------|
| [`SECURITY.md`](SECURITY.md) | Secrets, encryption/BYOK, OWASP, privacy & logging |
| [`ACCESSIBILITY.md`](ACCESSIBILITY.md) | WCAG targets, UI non-negotiables, CI vs manual |
| [`AI_INTEGRATION.md`](AI_INTEGRATION.md) | APIs, schemas, MCP, agent-friendly UX |
| [`ARCHITECTURE.md`](ARCHITECTURE.md) | Evolving system shape (fill per product) |
| [`docs/features/`](docs/features/) | Living feature docs (purpose, behavior, edge cases, decisions) |
| [`scaffold/PROJECT_CREATION.md`](scaffold/PROJECT_CREATION.md) | Day-one checklist including CI |
| [`README.md`](README.md) | How to use this repo — terminal apply via `scaffold/apply.sh` |
| [`ADOPT.md`](ADOPT.md) | Prompt-only / beginner path (Cursor, Claude Code, Codex, Lovable, …) |

---

## 0. Guiding Principles (Non-Negotiables)

1. **Future-safe by default**  
   Anything painful to retrofit later (encryption, compliance, accessibility) must be planned now.

2. **Explicit contracts beat implicit behavior**  
   APIs, schemas, logs, tests, and tools must be self-describing and stable.

3. **AI-first is real**  
   Systems must be easy for machines to understand, not just humans.

4. **Compliance without heroics**  
   GDPR, security, and accessibility are outcomes of design—not cleanup tasks.

5. **CI is part of creation, not cleanup**  
   A product is not scaffolded until required CI gates exist and block merge. Prompt rules without pipelines are aspirational only.

---

## 1. Code Structure & Typing

- Avoid deeply nested functions; extract small, named units with clear responsibilities.
- In typed languages, avoid wildcard types, `any`, and equivalent type-system escape hatches.
- Never use global variables; pass state and dependencies explicitly.
- Prefer extending existing modules over new files; no new third-party dependencies without explicit approval (see `AGENTS.md` — Minimal change).
- Existing public interfaces stay unchanged unless the change is explicitly requested.
- Gate incomplete capabilities behind **feature flags / env** documented in `.env.example` (or equivalent) — do not leave half-shipped paths reachable in production builds without an explicit off switch.

---

## 2. Testing Philosophy

- Tests describe **behavior**, not implementation.
- Tests are written in **separate commits** from features.
- Tests are immutable unless behavior or requirements change.
- Security and accessibility behavior have first-class homes — see [`SECURITY.md`](SECURITY.md) and [`ACCESSIBILITY.md`](ACCESSIBILITY.md) — not only SAST / URL axe.

### Commit Discipline
1. Feature commit  
2. Test commit  
3. Optional refactor commit  

Never modify tests just to make CI pass, or silence failing tests without explanation.

### Required Coverage
- Core domain logic
- API contracts
- Permission and authorization boundaries
- Regression tests for bugs

> Deleting a test requires a written justification.

---

## 3. Continuous Integration (Required at Project Creation)

Full checklist: [`scaffold/PROJECT_CREATION.md`](scaffold/PROJECT_CREATION.md).  
Apply tool: [`scaffold/apply.sh`](scaffold/apply.sh) (see [`README.md`](README.md)).  
Workflows: [`scaffold/ci/`](scaffold/ci/).

### Non-Negotiables
- Install scaffold CI on day one — before feature work (prefer `apply.sh`).
- Required checks are **merge-blocking** on the default branch.
- Exceptions are explicit, time-bounded, and recorded in [`SECURITY.md`](SECURITY.md).
- Wire real lint / typecheck / test commands in the creation PR — no no-op jobs.
- Provide a **local verify umbrella** (script or Make target) that mirrors merge gates as closely as practical — so “green locally” means the same family of checks as CI, not a random subset.

### Required Gates
**Always:** secrets scan, dependency review, SAST, quality (lint/types/tests).  
**When UI exists:** accessibility.  
**When a public API exists:** OpenAPI (or equivalent) lint in CI — see [`AI_INTEGRATION.md`](AI_INTEGRATION.md).  
**Specialist reviewers** (OWASP, a11y, privacy) complement CI; they never replace it.

### Creation Definition of Done
1. Docs + workflows applied via [`scaffold/apply.sh`](scaffold/apply.sh) (or equivalent hand copy)
2. GitHub remote exists; baseline landed via **PR merged to `main`** (not local-only commits)
3. Branch protection enabled on `main` before feature work
4. `CANON_NEXT_STEPS.md` completed and removed
5. CI green on a smoke baseline after quality commands are real
6. Secrets managed outside git — documented in `SECURITY.md`
7. Product-specific blanks filled in `SECURITY.md`, `ACCESSIBILITY.md`, `AI_INTEGRATION.md`, `ARCHITECTURE.md` (templates are not done)
8. Local verify umbrella documented (README or package scripts / Makefile)

---

## 4. Repo-Level Enforcement

### Required Files
- `AGENTS.md`
- `PROJECT_RULES.md` (this file)
- `ARCHITECTURE.md`
- `SECURITY.md`
- `AI_INTEGRATION.md`
- `ACCESSIBILITY.md`
- `docs/features/` (README + `_TEMPLATE.md`; feature files as capabilities ship)
- `.github/workflows/` from `scaffold/ci/`

### Living plan + feature docs
- **`docs/features/<capability>.md`** — decision/behavior record per capability.
- **README (or `PLAN.md`) Done / Next / Later** — living backlog surface. Update in the same PR as capability ships. Both are useful; neither replaces the other.

### How Agents Should Load Rules
- Always: `AGENTS.md` + `PROJECT_RULES.md`
- When touching auth, data, crypto, deps, or public APIs → `SECURITY.md`
- When touching UI → `ACCESSIBILITY.md`
- When touching APIs, tools, or agent surfaces → `AI_INTEGRATION.md`
- When changing system shape → `ARCHITECTURE.md`
- When adding or changing a capability → matching `docs/features/<capability>.md` (create/update in the same PR); refresh Done / Next / Later if you keep that surface

### Agent usage
- Prefer clarity over cleverness.
- Ask before violating a rule.
- Treat missing CI or missing domain docs as a scaffolding defect.
- Produce changes for **understanding to participate** (see `AGENTS.md`) — short summaries by default; literate explainers and check questions only when the change is non-trivial.
- Canon is **agent-agnostic** (any tool that reads these Markdown files). **GitHub is the default forge/CI**; other hosts should mirror remote → MR → merge-blocking checks (see [`ADOPT.md`](ADOPT.md)).

---

## 5. Regular Smell Tests

- Could we support BYOK tomorrow? → `SECURITY.md`
- Could an LLM understand this system in one page? → `AI_INTEGRATION.md` / `ARCHITECTURE.md`
- Could a blind user complete the core flow? → `ACCESSIBILITY.md`
- Could we fully delete a user within an hour? → `SECURITY.md` (privacy)
- Would we trust these logs during a breach disclosure? → `SECURITY.md`
- Would a violating PR be blocked by CI today? → `scaffold/ci/`
- Did the last capability land as its own branch + PR, or as uncommitted pile-on? → `AGENTS.md` (Delivery default)
- Did the last change stay local to the problem, or sprawl / add unasked deps? → `AGENTS.md` (Minimal change)
- Did the last relevant eval smoke/scenario still pass? → `evals/`
- Did the last stuck agent hand back the wheel (or roll back a bad slice) instead of thrashing? → `AGENTS.md` (When stuck / when wrong)
- If we publish an API, is OpenAPI (or equivalent) linted in CI? → `AI_INTEGRATION.md`
- Is there a local command that mirrors merge gates? → `PROJECT_RULES.md` (CI)
- Are Done / Next / Later and feature docs both current for recent ships? → README / `docs/features/`
- Did the agent merge a PR without an explicit “merge …” ask? → `AGENTS.md` (Delivery — never merge unless asked)

If any answer is “probably not” → stop and fix it.

---

## Versioning
- This document and the domain rulebooks are versioned.
- Changes require explicit rationale.
- Rules are additive unless explicitly deprecated.
