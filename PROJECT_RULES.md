# Project Engineering Rules (v1)

Portable engineering norms for products scaffolded from this repository. Always-on and kept short.  
What to load, and when, lives in [`AGENTS.md`](AGENTS.md). Domain detail lives in the rulebooks it points to.

---

## 0. Guiding principles (non-negotiables)

1. **Future-safe by default.** Anything painful to retrofit later (encryption, compliance, accessibility) is planned now.
2. **Explicit contracts beat implicit behaviour.** APIs, schemas, logs, tests, and tools are self-describing and stable.
3. **AI-first is real.** Systems are easy for machines to understand, not just humans.
4. **Compliance without heroics.** GDPR, security, and accessibility are outcomes of design, not cleanup tasks.
5. **CI is part of creation, not cleanup.** A product is not scaffolded until required CI gates exist and block merge. Prompt rules without pipelines are aspirational only.

---

## 1. Code structure and typing

- Avoid deeply nested functions; extract small, named units with clear responsibilities.
- In typed languages, avoid wildcard types, `any`, and equivalent escape hatches.
- Never use global variables; pass state and dependencies explicitly.
- Prefer extending existing modules over new files; no new third-party dependencies without explicit approval.
- Existing public interfaces stay unchanged unless the change is explicitly requested.
- Gate incomplete capabilities behind **feature flags / env** documented in `.env.example` (or equivalent). No half-shipped paths reachable in production without an off switch.

---

## 2. Testing

- Tests describe **behaviour**, not implementation, and are immutable unless behaviour or requirements change.
- Tests go in **separate commits** from features: feature, then test, then optional refactor.
- Never modify tests just to make CI pass, or silence failing tests without explanation. Deleting a test needs a written justification.
- Required coverage: core domain logic, API contracts, permission and authorisation boundaries, regression tests for bugs.
- Security and accessibility behaviour have first-class homes in [`SECURITY.md`](SECURITY.md) and [`ACCESSIBILITY.md`](ACCESSIBILITY.md), not only SAST / URL axe.

---

## 3. Continuous integration

Install scaffold CI on day one, before feature work (prefer [`scaffold/apply.sh`](scaffold/apply.sh)). Workflows: [`scaffold/ci/`](scaffold/ci/). Full checklist and definition of done: [`scaffold/PROJECT_CREATION.md`](scaffold/PROJECT_CREATION.md).

- Required checks are **merge-blocking** on the default branch. Exceptions are explicit, time-bounded, and recorded in [`SECURITY.md`](SECURITY.md).
- Wire real lint / typecheck / test commands in the creation PR. No no-op jobs.
- Provide a **local verify umbrella** (script or Make target) that mirrors merge gates as closely as practical.
- **Always:** secrets scan, dependency review, SAST, quality. **When UI exists:** accessibility. **When a public API exists:** OpenAPI lint ([`AI_INTEGRATION.md`](AI_INTEGRATION.md)).
- Specialist reviewers (OWASP, a11y, privacy) complement CI; they never replace it.

---

## 4. Repo-level enforcement

Required files: `AGENTS.md`, `PROJECT_RULES.md`, `ARCHITECTURE.md`, `HOUSE_STYLE.md`, `SECURITY.md`, `AI_INTEGRATION.md`, `ACCESSIBILITY.md`, `docs/agent/`, `docs/features/` (README + `_TEMPLATE.md`), `docs/house-style/` (README + profiles; living file is `HOUSE_STYLE.md`), and `.github/workflows/` from `scaffold/ci/`.

Living records: `docs/features/<capability>.md` per capability, and a README (or `PLAN.md`) Done / Next / Later list. Update both in the same PR as the capability ships.

Missing CI or missing domain docs is a scaffolding defect. Ask before violating a rule.

---

## Versioning

Rules are versioned and additive unless explicitly deprecated. Changes need a written rationale.
