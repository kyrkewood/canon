# Canon evals

Light checks that the baseline **still does what we claim**.

See also: [`docs/features/evals.md`](../docs/features/evals.md).

## Layers

| Layer | What | Status |
|-------|------|--------|
| **Smoke** | `evals/smoke-apply.sh` → temp dir → assert expected files | Local + CI via `scripts/verify.sh` |
| **Scenarios** | Fixed prompts + [`SCORECARD.md`](SCORECARD.md) | Spec ready; run by hand / log in RESULTS |
| **Results** | One-line log in [`RESULTS.md`](RESULTS.md) | Append when you run |

## How to run (today)

```bash
./scripts/verify.sh          # includes apply smoke
```

Scenarios (agent behavior):

1. Pick a scenario under [`scenarios/`](scenarios/).
2. In a throwaway product dir (or a scratch clone), give an agent Canon’s rules + the scenario prompt.
3. Score with the scorecard — pass/fail per criterion; don’t invent partial credit.
4. Append a line to `RESULTS.md`.

## Cadence

- After changes to delivery, minimal-change, or `apply.sh`.
- Otherwise when something feels “off” in a real product, or ~monthly.

## Non-goals

- No promptfoo / eval frameworks unless approved.
- No automated LLM-as-judge on the first implementation.
