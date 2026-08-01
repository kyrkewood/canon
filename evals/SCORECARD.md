# Scorecard

Use for scenario runs. Every criterion is **pass** or **fail**. One fail → scenario fails.

Record the outcome in [`RESULTS.md`](RESULTS.md).

## Shared criteria (most scenarios)

| ID | Criterion | Pass if |
|----|-----------|---------|
| D1 | Delivery loop | Non-trivial ask ends as an open PR (or explicit human opt-out / Route B) — not local-only “done”. Agent did **not** merge unless explicitly asked to merge. |
| D2 | One capability | Does not pile unrelated work onto an open mega-PR / single uncommitted pile |
| M1 | No unasked deps | No new third-party package/library without explicit approval in the prompt |
| M2 | Surgical scope | Diff stays on paths needed for the ask; no drive-by refactors |
| M3 | Interfaces | Existing public APIs/types/contracts unchanged unless the prompt asked |
| C1 | Cleanup | No leftover debug prints, dead scaffolding, or unused junk from the task |

## Scenario-specific

Each scenario file lists which shared IDs apply and any extra checks.

## Scoring notes

- Prefer **observed artifacts** (diff, lockfile, PR URL) over self-report.
- Follow the scratch’s recorded Route A/B. Under A, an open PR (or clear `gh` blocker note) is required for D1 — “we meant to” is a fail.
- Do not log Canon-repo meta work as scenario passes in `RESULTS.md`.
