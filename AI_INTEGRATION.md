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
- Publish OpenAPI / JSON Schema **in the repo**.
- Write endpoint and field descriptions for **LLMs**, not just developers.
- Prefer semantic names (`CreateInvoice`) over generic verbs.

### When a public API exists (CI)
- Checked-in OpenAPI (or equivalent) is **linted in CI** — not docs-only aspiration.
- Prefer a dedicated step or job; do not leave “we have a yaml somewhere” without a failing gate on drift/invalid specs.
- Tooling is product choice (Redocly, Spectral, etc.). Canon does not mandate a vendor.
- If you also publish a docs site that embeds the spec, keep a **deterministic check** that the published copy matches the repo source (or is generated from it).

### Persistence & client state contracts
- Versioned JSON Schema is not only for HTTP. Durable client/local app state should use versioned schemas (e.g. `*.v1.json`) and a short `SCHEMA.md` (or equivalent) describing compatibility and migration.
- Database shape: when durable server data exists, keep incremental docs (`SCHEMA.md`, optional roadmap note) in sync with migrations — principles in [`SECURITY.md`](SECURITY.md) / this file; SQL stays product-specific.

### Dual-runtime contracts
- When the same contract runs in two places (e.g. edge function ↔ app, worker ↔ API), share one module or generate from one source. Do not maintain divergent copies by hand.

### API evolution (optional docs)
- A short phased API plan (what ships now vs next) is useful; hardening concerns (idempotency keys, rate limits, audit logs) belong in design notes.
- Do **not** treat product-specific SQL/hardening recipes as Canon baseline — document concerns, implement per stack.

---

## 3. MCP / Tooling

- MCP is a first-class interface, not an adapter.
- Tool calls must be:
  - Idempotent
  - Explicit about side effects
  - Permission-scoped
- **If an MCP server exists:** give it a real package (or clear entrypoint), tests/lint as appropriate, and include it in the local verify umbrella and CI — not a README placeholder.

---

## 4. “Frontend for AIs”

- Minimal, text-first UI where an agent-facing surface exists.
- Clear system state summaries.
- No reliance on visual layout or color for meaning.
- Predictable, deterministic responses.
- Optional root [`llms.txt`](https://llmstxt.org/) (or equivalent) summarizing when to use the product, key endpoints, and MCP tools — complements OpenAPI.

Goal: an LLM can understand the product in <30 tokens and predict outcomes before calling tools.

---

## 5. Product-Specific Notes

_Fill in at project creation:_

- Public API base URL / version:
- OpenAPI / schema location + CI lint command:
- Persistence / client schema location (if any):
- MCP server entrypoint + CI path (if any):
- `llms.txt` (or equivalent) location:
- Side-effecting tools and their auth scopes:
- Docs site (if any) and how the OpenAPI copy stays in sync:
