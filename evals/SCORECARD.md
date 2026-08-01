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

- Prefer **observed artifacts** (git status, PR URL, `package.json` / lockfile diff, file list) over the agent’s self-report.
- Host “don’t commit unless asked” vs Canon delivery: **pass** if apply/product recorded Route A or B and the agent followed it (quiet delivery under A; ask-first under B). Fail if it silently skips the PR under A, silently commits under B, or never flags an unresolved conflict.
