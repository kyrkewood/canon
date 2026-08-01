# Feature: Canon evals

## Purpose

A **light, repeatable check** that Canon’s agent rules and apply path stay valuable — not a full eval platform. Catches regressions like “delivery loop ignored” or “unasked dependency added” before they become habit.

## How it should work

1. **Mechanical smoke** (`evals/smoke-apply.sh`, also via `scripts/verify.sh` / CI): run `apply.sh` into a temp dir and assert the expected baseline file set (and that next-steps aren’t empty lies).
2. **Scenarios** (human- or agent-run): fixed prompts in `evals/scenarios/`; score with `evals/SCORECARD.md` (pass/fail, no LLM judge required).
3. **Log**: one line per run in `evals/RESULTS.md` (date, scenario or smoke, pass/fail, short note).

Cadence: after material changes to `AGENTS.md`, `apply.sh`, or delivery/minimal-change rules; otherwise occasionally (e.g. monthly).

## Non-goals

- No new eval library (promptfoo, etc.) unless explicitly approved.
- No automated LLM-as-judge (first runs stay checklist-scored).
- No claim that green smoke alone proves “Canon works.”
- Not a product-app test suite; scenarios are tiny fixtures / prompts only.

## Edge cases & failure modes

- Agent host rules conflict with Canon delivery → scenario should still require stop + callout, not silent local-only “done.”
- Overfitting: don’t add scenarios that only pass by copying Canon wording; score observed behavior (branch/PR, file/deps touched).
- CI should stay cheap: smoke only in CI until a human opts into heavier checks.

## Decisions

| Date | Decision | Why | Revisit when |
|------|----------|-----|--------------|
| 2026-07-28 | Docs-first; implement smoke + CI in a follow-up PR | Design before ceremony | After first smoke lands |
| 2026-07-28 | Checklist scorecard, not LLM judge | Cheap, reviewable, less flaky | If volume of runs makes manual scoring a bottleneck |
| 2026-08-01 | Smoke + `scripts/verify.sh` + CI workflow shipped | Dogfood local-verify convention | If verify becomes slow or flaky |

## Open questions

- Whether RESULTS.md stays committed one-liners (yes for now).
- Exact file assertions for stack variants (`node` / `python`, `--with-ui`) beyond `--stack=none`.
