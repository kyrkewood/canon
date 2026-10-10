# End-of-task checklist

Loaded from [`AGENTS.md`](../../AGENTS.md) before calling work done. If any answer is "probably not", stop and fix it.

- BYOK / delete-user / trusted logs / no raw PII? → [`SECURITY.md`](../../SECURITY.md)
- LLM can orient in one page? → [`AI_INTEGRATION.md`](../../AI_INTEGRATION.md) / [`ARCHITECTURE.md`](../../ARCHITECTURE.md)
- Blind user can complete core flow? → [`ACCESSIBILITY.md`](../../ACCESSIBILITY.md)
- Violating PR blocked by CI today? Local verify mirrors gates? → `scaffold/ci/` / `scripts/verify.sh` (or product umbrella)
- Last capability on its own branch with an open PR (not pile-on); no merge without "merge …"? → [`git-delivery.md`](git-delivery.md)
- Last PR copy skim-sized; UI changes have before/after shots? → [`pull-requests.md`](pull-requests.md)
- Last change surgical, no unasked deps? → [`AGENTS.md`](../../AGENTS.md)
- New prose follows [`HOUSE_STYLE.md`](../../HOUSE_STYLE.md) without renaming identifiers or APIs?
- Last eval smoke/scenario still honest? → `evals/`
- Stuck agent handed back the wheel? → [`AGENTS.md`](../../AGENTS.md)
- API OpenAPI linted if published? Plan and feature docs current? → [`AI_INTEGRATION.md`](../../AI_INTEGRATION.md) / README / `docs/features/`
