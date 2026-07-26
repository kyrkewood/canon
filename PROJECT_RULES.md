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
| [`scaffold/PROJECT_CREATION.md`](scaffold/PROJECT_CREATION.md) | Day-one checklist including CI |

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

---

## 2. Testing Philosophy

- Tests describe **behavior**, not implementation.
- Tests are written in **separate commits** from features.
- Tests are immutable unless behavior or requirements change.

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
Workflows: [`scaffold/ci/`](scaffold/ci/).

### Non-Negotiables
- Install scaffold CI on day one — before feature work.
- Required checks are **merge-blocking** on the default branch.
- Exceptions are explicit, time-bounded, and recorded in [`SECURITY.md`](SECURITY.md).
- Wire real lint / typecheck / test commands in the creation PR — no no-op jobs.

### Required Gates
**Always:** secrets scan, dependency review, SAST, quality (lint/types/tests).  
**When UI exists:** accessibility.  
**Specialist reviewers** (OWASP, a11y, privacy) complement CI; they never replace it.

### Creation Definition of Done
1. `AGENTS.md` + this file + domain docs below  
2. CI workflows installed and green on a smoke baseline  
3. Branch protection requiring the gates  
4. Secrets outside git, documented in `SECURITY.md`

---

## 4. Repo-Level Enforcement

### Required Files
- `AGENTS.md`
- `PROJECT_RULES.md` (this file)
- `ARCHITECTURE.md`
- `SECURITY.md`
- `AI_INTEGRATION.md`
- `ACCESSIBILITY.md`
- `.github/workflows/` from `scaffold/ci/`

### How Agents Should Load Rules
- Always: `AGENTS.md` + `PROJECT_RULES.md`
- When touching auth, data, crypto, deps, or public APIs → `SECURITY.md`
- When touching UI → `ACCESSIBILITY.md`
- When touching APIs, tools, or agent surfaces → `AI_INTEGRATION.md`
- When changing system shape → `ARCHITECTURE.md`

### Cursor Usage
- Prefer clarity over cleverness.
- Ask before violating a rule.
- Treat missing CI or missing domain docs as a scaffolding defect.
- Produce PRs for **understanding to participate** (see `AGENTS.md`) — short bodies by default; literate explainers and check questions only when the change is non-trivial.

---

## 5. Regular Smell Tests

- Could we support BYOK tomorrow? → `SECURITY.md`
- Could an LLM understand this system in one page? → `AI_INTEGRATION.md` / `ARCHITECTURE.md`
- Could a blind user complete the core flow? → `ACCESSIBILITY.md`
- Could we fully delete a user within an hour? → `SECURITY.md` (privacy)
- Would we trust these logs during a breach disclosure? → `SECURITY.md`
- Would a violating PR be blocked by CI today? → `scaffold/ci/`

If any answer is “probably not” → stop and fix it.

---

## Versioning
- This document and the domain rulebooks are versioned.
- Changes require explicit rationale.
- Rules are additive unless explicitly deprecated.
