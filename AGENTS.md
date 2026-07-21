# AGENTS.md

Standing instructions for coding agents. Follow these every session, on every task.

## Rules hierarchy

- Read and follow [`PROJECT_RULES.md`](PROJECT_RULES.md) before planning or changing code.
- `AGENTS.md` governs agent workflow and delivery.
- `PROJECT_RULES.md` governs engineering, security, accessibility, testing, and architecture.
- When rules conflict, follow the stricter rule and call out the conflict before proceeding.

## Verify delivery against spec

After any task, check that every component requested was actually delivered — not just the headline feature. If you asked for five things, confirm five things exist. Don't let partial delivery pass as "done."

## Distrust green checkmarks

Passing tests and green CI are not proof of correctness. Before declaring something complete:

- Read the actual implementation, not just the test output.
- Watch for hardcoded return values, stubbed logic, mocked-out core paths, or tests that assert trivially true things.
- If a test looks too easy to pass, ask why — it may be testing the mock instead of the behavior.

## Specify quality explicitly, not just function

State what the code should do, how it should be structured, and what standard it should meet (error handling, edge cases, naming, performance, style conventions). Ambiguous requests get bare-minimum implementations by default — precision in the ask is what raises the quality of the output.

## Clean up as part of the task, not after

Every task includes explicit cleanup: remove dead code, unused imports/variables, leftover debug prints, temp files, and scaffolding created along the way. Don't leave the codebase messier than before the task started.

## Commit every change/step

Commit incrementally as work progresses, not in one giant commit at the end. Each logical step (a working feature slice, a passing test, a refactor) gets its own commit with a clear message, so history is reviewable and any step can be rolled back independently.

## Prepare work for review, not just for merging

- When finishing a task, produce a short explainer before the diff: state the goal, give relevant background, then walk through the changes in a sensible order (not a raw alphabetical diff).
- For non-trivial or unfamiliar changes, offer 3–5 quick check questions so the reviewer can confirm they actually understood the change, not just skimmed it.
- For changes that are hard to review by reading alone (framework migrations, algorithm changes, unfamiliar libraries), consider building a small step-through tool or visualization so the reviewer can watch the change happen rather than take it on faith.

## Trust but verify, always

"It works" is not the finish line. Re-check completed work against the original ask, re-read implementation details, and re-run relevant tests/tools yourself rather than accepting a summary of success at face value. Assume the AI defaults to the minimum viable version of any task unless explicitly pushed further.
