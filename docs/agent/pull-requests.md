# Pull requests: understand to participate

Loaded from [`AGENTS.md`](../../AGENTS.md) when writing or reviewing a PR.

Understanding – not generation – is the bottleneck. Review exists so humans can **steer the next loop**, not only approve the last one. Avoid cognitive debt: shipping code nobody can fluently evolve.

The PR body is a **skim**: what changed and why. The diff is the deep dive. Do not write a second copy of the change in prose.

## PR body

- Default: **1–3 bullets** (what / why). Add risk or test notes only when non-obvious.
- Size copy to the change: a one-line fix gets a one-line PR.
- Do **not** restate the diff, pad with template sections, or write an essay.
- **Why means the problem.** Name what was wrong or confusing for the user, not just what the new behaviour is. "Clearer wording" is not a why.

## Before and after (when wording or behaviour changed)

When the PR changes text a person reads, or behaviour they can observe, give the old and new in one line each, then the problem the old version caused. This replaces prose that restates the diff; it does not add to it.

> **Before:** "Run the blinds timer, seating, knockouts, and prizes from this app"
> **After:** "Blinds timer, plus optional seating, knockouts, and prizes – use as much or as little as you need. Just the clock is fine."
> **Why:** The old line read as all-or-nothing, so someone wanting only a timer could skip Full tournament.

Quote the strings for copy; describe the observable difference for behaviour. Skip it for refactors, docs, and anything with no user-visible delta.

## Screenshots (when UI changed)

If the PR changes anything a person can see (layout, styling, routing, client-rendered data, **copy**), attach **before and after** screenshots of the affected surfaces. A copy-only change is still visible; "it's one string" is not a reason to skip.

- Crop to the change; one pair per distinct view is enough.
- Skip when there is no visual delta (docs, backend, Markdown-only).
- Stills by default. A short clip only if motion or interaction *is* the change.
- No real secrets or PII in shots.

## Literate walkthrough (when non-trivial)

Before asking for review on a non-obvious change, produce a short explainer (comment or linked doc – not extra bulk in the PR body):

1. **Background** – what already existed
2. **Intuition** – goal and essence, before code
3. **Literate diff** – walk changes in teaching order (not file-alpha), with small snippets only where they teach

Skip this for trivial PRs. Bloat is a failure mode equal to under-explaining.

## Check questions

For non-trivial PRs, end the explainer with **3–5** questions the author can answer cold before requesting review. Same bar when reviewing others. Omit on trivial changes.

## Micro-worlds (rare)

Only when reading cannot build intuition (eg, migrations, unfamiliar engines, tricky algorithms): a tiny step-through or visualisation the reviewer can operate – not a second product.
