# Project Engineering Rules (v1)

A portable, opinionated rulebook for projects scaffolded from this repository.  
These rules bias every project toward **security, compliance, accessibility, testability, and AI-first integration** from day one.

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

---

## 1. Code Structure & Typing

### Rules
- Avoid deeply nested functions; extract small, named units with clear responsibilities.
- In typed languages, avoid wildcard types, `any`, and equivalent type-system escape hatches.
- Never use global variables; pass state and dependencies explicitly.

---

## 2. Encryption & Key Management (BYOK-Ready)

### Rules
- All sensitive data **must be encryptable at rest**.
- Encryption logic must be **decoupled from any specific cloud KMS**.
- Keys must be **rotatable without data migration**.
- Encryption boundaries must align with **customer isolation**.
- **Never put keys in version control.**
- **Always use a secrets manager.**

### Required Design Patterns
- Introduce a `KeyProvider` abstraction even if only env-based keys are used initially.
- Use envelope encryption:
  - Per-customer DEK
  - Master key (future BYOK)
- Persist metadata:
  - `customer_id`
  - `key_id`
  - `encryption_version`

### Smell Test
> If this table leaked, could we honestly say “the data is encrypted with customer-controlled keys”?

If not, redesign.

---

## 3. Logging, Telemetry & GDPR Compliance

### Rules
- Logs are **diagnostic**, not archival.
- **No raw PII** in logs—ever.
- Logs must be structured, redactable, and correlatable.

### Mandatory Log Fields
- `event_name`
- `timestamp`
- `request_id`
- `customer_id` (hashed or pseudonymous)
- `data_classification` (`public | internal | sensitive`)

### PII Handling
- Hash identifiers (email, user ID) with a salt.
- Truncate or summarize free-text inputs.
- Maintain an explicit allowlist of loggable fields.

### GDPR Defaults
- Logs have TTLs.
- Logs are region-aware.
- Deletion hooks exist for:
  - User data
  - Derived data
  - Cached AI outputs

> If it can’t be deleted, it shouldn’t be logged.

---

## 4. AI-First Integration Strategy

### North Star
The product should be the **obvious choice for an AI agent** to integrate with—no human glue code required.

### Rules
- Every core capability must be reachable via an API.
- APIs must have machine-readable schemas.
- Human UI is optional. **AI UX is not.**

### API Design
- Narrow, explicit endpoints.
- Stable, versioned schemas.
- Deterministic error shapes.
- Idempotent operations where possible.

### AI-Friendly Contracts
- Publish OpenAPI / JSON Schema.
- Write endpoint and field descriptions for **LLMs**, not just developers.
- Prefer semantic names (`CreateInvoice`) over generic verbs.

### MCP / Tooling
- MCP is a first-class interface, not an adapter.
- Tool calls must be:
  - Idempotent
  - Explicit about side effects
  - Permission-scoped

### “Frontend for AIs”
- Minimal, text-first UI.
- Clear system state summaries.
- No reliance on visual layout or color.
- Predictable, deterministic responses.

Goal: an LLM can understand the product in <30 tokens and predict outcomes before calling tools.

---

## 5. Accessibility (AAA by Default)

### Rules
- Target **WCAG AAA** by default.
- Accessibility failures are bugs.

### Non-Negotiables
- Full keyboard navigation everywhere.
- Screen readers receive:
  - Correct landmarks
  - Meaningful labels
  - Predictable focus order
- Color contrast is validated automatically.

### Enforcement
- Accessibility checks in CI.
- No PR merged without:
  - Passing automated a11y tests
  - Manual keyboard walkthrough

Bonus: AI agents navigating the UI will also work better.

---

## 6. Testing Philosophy

### Rules
- Tests describe **behavior**, not implementation.
- Tests are written in **separate commits** from features.
- Tests are immutable unless behavior or requirements change.

### Commit Discipline
1. Feature commit
2. Test commit
3. Optional refactor commit

Never:
- Modify tests just to make CI pass.
- Silence failing tests without explanation.

### Required Test Coverage
- Core domain logic
- API contracts
- Permission and authorization boundaries
- Regression tests for bugs

> Deleting a test requires a written justification.

---

## 7. Repo-Level Enforcement

### Required Files
- `PROJECT_RULES.md`
- `ARCHITECTURE.md` (short, evolving)
- `SECURITY.md`
- `AI_INTEGRATION.md`
- `ACCESSIBILITY.md`

### Cursor Usage
- Feed `PROJECT_RULES.md` as system context.
- Instruct Cursor to:
  - Follow these rules
  - Ask before violating them
  - Prefer clarity over cleverness

The goal is to turn Cursor into a **staff-level engineer with opinions**.

---

## 8. Regular Smell Tests

Ask frequently:
- Could we support BYOK tomorrow?
- Could an LLM understand this system in one page?
- Could a blind user complete the core flow?
- Could we fully delete a user within an hour?
- Would we trust these logs during a breach disclosure?

If any answer is “probably not” → stop and fix it.

---

## Versioning
- This document is versioned.
- Changes require explicit rationale.
- Rules are additive unless explicitly deprecated.

---

**End of Ruleset**
