# AI Integration

Domain rulebook for making the product the obvious choice for agents and tools.  
Parent index: [`PROJECT_RULES.md`](PROJECT_RULES.md).

---

## 1. North Star

The product should be the **obvious choice for an AI agent** to integrate with—no human glue code required.

- Every core capability must be reachable via an API.
- APIs must have machine-readable schemas.
- Human UI is optional. **AI UX is not.**

---

## 2. API Design

- Narrow, explicit endpoints.
- Stable, versioned schemas.
- Deterministic error shapes.
- Idempotent operations where possible.

### AI-Friendly Contracts
- Publish OpenAPI / JSON Schema.
- Write endpoint and field descriptions for **LLMs**, not just developers.
- Prefer semantic names (`CreateInvoice`) over generic verbs.

---

## 3. MCP / Tooling

- MCP is a first-class interface, not an adapter.
- Tool calls must be:
  - Idempotent
  - Explicit about side effects
  - Permission-scoped

---

## 4. “Frontend for AIs”

- Minimal, text-first UI where an agent-facing surface exists.
- Clear system state summaries.
- No reliance on visual layout or color for meaning.
- Predictable, deterministic responses.

Goal: an LLM can understand the product in <30 tokens and predict outcomes before calling tools.

---

## 5. Product-Specific Notes

_Fill in at project creation:_

- Public API base URL / version:
- OpenAPI / schema location:
- MCP server entrypoint (if any):
- Side-effecting tools and their auth scopes:
