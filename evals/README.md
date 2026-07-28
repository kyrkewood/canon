# Canon evals

Light checks that the baseline **still does what we claim**.

See also: [`docs/features/evals.md`](../docs/features/evals.md).

## Layers

| Layer | What | Status |
|-------|------|--------|
| **Smoke** | `apply.sh` → temp dir → assert expected files | Next PR (+ CI) |
| **Scenarios** | Fixed prompts + [`SCORECARD.md`](SCORECARD.md) | Spec in this PR; run by hand |
| **Results** | One-line log in [`RESULTS.md`](RESULTS.md) | Start empty; append when you run |

## How to run (today)

1. Pick a scenario under [`scenarios/`](scenarios/).
2. In a throwaway product dir (or a scratch clone), give an agent Canon’s rules + the scenario prompt.
3. Score with the scorecard — pass/fail per criterion; don’t invent partial credit.
4. Append a line to `RESULTS.md`.

## How to run (after implement PR)

- `evals/smoke-apply.sh` (local and CI) for mechanical apply.
- Same scenario loop as above; CI does **not** run agents by default.

## Cadence

- After changes to delivery, minimal-change, or `apply.sh`.
- Otherwise when something feels “off” in a real product, or ~monthly.

## Non-goals

- No promptfoo / eval frameworks unless approved.
- No automated LLM-as-judge on the first implementation.
