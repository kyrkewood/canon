# Feature: Product conventions from field use

## Purpose

Fold patterns proven in real Canon products back into the baseline as **conventions and gates** — without shipping stack-specific implementations (VitePress, Redocly, Deno, crypto modules, Cursor `.mdc` rules).

## How it should work

When a product has the relevant surface, Canon expects:

| Surface | Convention |
|---------|------------|
| Public API | Checked-in OpenAPI (or equivalent) **linted in CI** |
| Durable client/DB state | Versioned schemas + short schema docs |
| MCP | Real package/entrypoint + CI / local verify |
| Security | In-repo security behavior tests + crypto/logger tests where those rules apply |
| UI a11y | URL axe **and** in-suite component a11y tests |
| Incomplete features | Env/feature-flag gates documented in `.env.example` |
| Backlog | README/`PLAN.md` Done·Next·Later **plus** `docs/features/` |
| Local CI | One verify umbrella mirroring merge gates |

Dual-runtime contracts share one source of truth. Product blanks in domain docs are filled in the creation PR.

## Non-goals

- No docs-site generator scaffold (VitePress, etc.).
- No mandated OpenAPI linter vendor.
- No copied KeyProvider/logger/MCP packages in `apply.sh`.
- No Cursor-only workflow rules in the required baseline.
- No hardening SQL recipes as Canon defaults.

## Edge cases & failure modes

- Treating OpenAPI as “docs we wrote once” without a CI lint step.
- Scaffolding empty MCP/crypto stubs that greenwash the rulebooks.
- Letting Done/Next/Later drift from shipped feature docs.

## Decisions

| Date | Decision | Why | Revisit when |
|------|----------|-----|--------------|
| 2026-08-01 | Conventions in domain docs + checklist; not new apply artifacts | Field-proven; keep Canon stack-agnostic | If many products need the same scaffold file set |

## Open questions

- Whether a later optional `scaffold/examples/` tree should show one reference layout (still non-default on apply).
