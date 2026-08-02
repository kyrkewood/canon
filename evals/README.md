# Canon evals

Light checks that the baseline **still does what we claim**.

See also: [`docs/features/evals.md`](../docs/features/evals.md).

## Layers

| Layer | What | Status |
|-------|------|--------|
| **Smoke** | [`smoke-apply.sh`](smoke-apply.sh) via [`scripts/verify.sh`](../scripts/verify.sh) | Local + CI |
| **Scenarios** | Fixed prompts + [`SCORECARD.md`](SCORECARD.md) on a **scratch product** | Manual; log in RESULTS |
| **Results** | [`RESULTS.md`](RESULTS.md) | Observed runs only — no diary passes |

## How to run

```bash
./scripts/verify.sh          # apply smoke
```

Scenarios:

1. Create a throwaway dir; seed any files the scenario needs; run `scaffold/apply.sh` into it.
2. Record Route A or B on the scratch.
3. Follow the scenario prompt **as the agent under test** (or have a cold agent do it).
4. Score with the scorecard from **artifacts** (diff, lockfile, PR URL).
5. Append one line to `RESULTS.md`.

`ship-capability` needs a real remote + `gh` (or score **fail** on D1 if you only have a local scratch — that is an honest fail, not a skip).

## Cadence

After changes to git authority, minimal-change, or `apply.sh`; otherwise when field use feels off.

## Non-goals

- No eval libraries / LLM-as-judge unless approved.
- No scoring Canon’s own PR history as a product scenario pass.
