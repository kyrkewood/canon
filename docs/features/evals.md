# Feature: Canon evals

## Purpose

A **light, repeatable check** that Canon’s agent rules and apply path stay valuable — not a full eval platform. Catches regressions like “delivery loop ignored” or “unasked dependency added” before they become habit.

## How it should work

1. **Mechanical smoke** (`evals/smoke-apply.sh`, also via `scripts/verify.sh` / CI).
2. **Scenarios** on a scratch product; score with `evals/SCORECARD.md`.
3. **Log** observed runs only in `evals/RESULTS.md`.

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
| 2026-07-28 | Checklist scorecard, not LLM judge | Cheap, reviewable | Volume makes manual scoring a bottleneck |
| 2026-08-01 | Smoke + verify in CI | Dogfood local-verify | Verify becomes slow/flaky |
| 2026-08-01 | RESULTS = observed scratch/CI only; meta diary removed | Evals were self-congratulatory | — |
| 2026-08-01 | Compress git authority in AGENTS; merge stays sacred | Scar tissue was crowding standing orders | Authority fights return |

## Open questions

- Disposable-remote harness for `ship-capability` without leaving junk GitHub repos.
