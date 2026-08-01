# Architecture

Short, evolving description of how this product is shaped.  
Parent index: [`PROJECT_RULES.md`](PROJECT_RULES.md).  
Keep this file small enough that an engineer or agent can re-orient in one screen.

---

## 1. Purpose

_What problem does this product solve, in one paragraph._

---

## 2. System Context

_Major actors, external systems, and trust boundaries. Link to diagrams if any._

---

## 3. Building Blocks

| Component | Responsibility | Notes |
|-----------|----------------|-------|
| _e.g. API_ | | |
| _e.g. Worker_ | | |
| _e.g. Data store_ | | |

---

## 4. Data & Tenancy

- Tenancy model:
- Sensitive data classes (see [`SECURITY.md`](SECURITY.md)):
- Encryption boundaries:
- Schema / persistence docs (see [`AI_INTEGRATION.md`](AI_INTEGRATION.md) — versioned contracts, `SCHEMA.md` when durable data exists):

---

## 5. Key Flows

_List 3–5 core flows (auth, create X, delete user, etc.). Link each to its feature doc under [`docs/features/`](docs/features/) when one exists._

When the same contract is executed in more than one runtime, note the shared source of truth (see dual-runtime contracts in [`AI_INTEGRATION.md`](AI_INTEGRATION.md)).

---

## 6. Decisions (ADR lite)

| Date | Decision | Why | Revisit when |
|------|----------|-----|--------------|
| | | | |

Product-wide decisions live here. Capability-level decisions live in the matching feature doc.

---

## 7. Open Risks

_Top risks and mitigations. Prefer linking security/privacy items to `SECURITY.md`._
