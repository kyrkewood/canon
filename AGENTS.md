# AGENTS.md

Standing instructions for coding agents. Follow these every session, on every task.

## Rules hierarchy

- Always read [`AGENTS.md`](AGENTS.md) (this file) and [`PROJECT_RULES.md`](PROJECT_RULES.md).
- `PROJECT_RULES.md` is the index; load domain rulebooks when the work touches that domain:
  - [`SECURITY.md`](SECURITY.md) — secrets, encryption, OWASP, privacy/logging
  - [`ACCESSIBILITY.md`](ACCESSIBILITY.md) — UI / WCAG
  - [`AI_INTEGRATION.md`](AI_INTEGRATION.md) — APIs, MCP, agent UX
  - [`ARCHITECTURE.md`](ARCHITECTURE.md) — system shape
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

Those commits live on a **feature branch**. Incremental commits are not a substitute for opening a PR.

## Delivery default: remote → branch → PR → main

**Non-negotiable for new products and for non-trivial work** (including applying Canon):

- Never treat local-only `main` (or unpushed commits) as done.
- Default loop: ensure a GitHub remote exists → work on a branch (`chore/canon-baseline`, `feat/…`, …) → push → open a PR → merge to `main` after checks.
- Direct push to `main` only when the human explicitly says so, or for a one-shot bootstrap they explicitly approve.
- Do **not** auto-merge. Open the PR; require green checks; human (or explicit ask) merges.
- If `gh` is missing or unauthenticated, stop and put that in `CANON_NEXT_STEPS.md` as a blocking item — do not silently skip the remote/PR.

This scaffolding rule wins over generic “only open a PR when asked” habits when the task is creating or applying a product baseline.

## Pull requests: understand to participate

Understanding—not generation—is the bottleneck. Review exists so humans can **steer the next loop**, not only thumbs-up the last one. Avoid cognitive debt: shipping code nobody can fluently evolve.

### PR body — less is more
- Default: **1–3 bullets** (what / why). Add risk or test notes only when non-obvious.
- Do **not** restate the diff, pad with template sections, or write an essay in the PR description.
- Size the artifact to the change: a one-line fix gets a one-line PR.

### Literate walkthrough (when non-trivial)
Before asking for review on a non-obvious change, produce a short explainer (comment, linked doc, or PR appendix—whichever stays readable):
1. **Background** — what already existed
2. **Intuition** — goal and essence, before code
3. **Literate diff** — walk changes in teaching order (not file-alpha), with small snippets only where they teach

Skip this for trivial PRs. Bloat is a failure mode equal to under-explaining.

### Check questions (speed regulator)
For non-trivial PRs, end the explainer with **3–5** questions the author can answer cold before requesting review. Same bar when reviewing others. Omit quizzes on trivial changes.

### Micro-worlds (rare)
Only when reading cannot build intuition (e.g. migrations, unfamiliar engines, tricky algorithms): a tiny step-through or visualization the reviewer can operate—not a second product.

## Trust but verify, always

"It works" is not the finish line. Re-check completed work against the original ask, re-read implementation details, and re-run relevant tests/tools yourself rather than accepting a summary of success at face value. Assume the AI defaults to the minimum viable version of any task unless explicitly pushed further.

## Scaffolding new products

When creating a new product from this baseline:

- **Prompt-only users:** point them at [`ADOPT.md`](ADOPT.md) (fetch & apply prompt).
- **Preferred (terminal):** from a canon clone, run `./scaffold/apply.sh /path/to/project` (see [`README.md`](README.md)), then finish `CANON_NEXT_STEPS.md` in the target.
- After apply: create or link a GitHub remote and open a PR to `main` — do not stop at local commits. Use `apply.sh --github` / `--open-pr` when available.
- Do not hand-copy files unless the script cannot run; if you must, follow [`scaffold/PROJECT_CREATION.md`](scaffold/PROJECT_CREATION.md).
- Wire real lint/typecheck/test commands — do not leave placeholder jobs that `exit 0` (or the refuse-empty stubs).
- Treat missing merge-blocking gates (secrets, deps, SAST, quality, and accessibility when UI exists) as a failed scaffold, not a follow-up task.
- Specialist security or accessibility reviews may run on later PRs; they complement CI and never replace it.
