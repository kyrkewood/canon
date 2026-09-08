# Feature: PR review as a skim

## Purpose

Keep pull requests easy to review: a short what/why, plus before/after screenshots when the UI changed, so a human can steer without reading a generated essay.

## How it should work

- The PR body is a **skim**. The code is the deep dive.
- Default body: 1–3 bullets (what changed and why). Scale copy to the change.
- When user-visible UI changes, attach before and after screenshots of the affected surfaces (cropped; one pair per distinct view).
- Skip shots when there is no visual delta.
- Literate walkthroughs and check questions stay for non-obvious work. Put them in a comment or linked doc if they would bloat the body.

See `AGENTS.md` — Pull requests.

## Non-goals

- Not a required GitHub PR template (empty sections fight proportional copy).
- Not a substitute for running the UI or for accessibility tests.
- Not screenshot CI / visual regression (that's a product choice).

## Edge cases & failure modes

- Screenshot galleries of every breakpoint when one pair would do.
- Omitting shots because "the CSS is in the diff".
- Restating the file list in prose.
- Putting a literate walkthrough in the body of a small change.

## Decisions

| Date | Decision | Why | Revisit when |
|------|----------|-----|--------------|
| 2026-09-08 | Skim body + UI before/after in `AGENTS.md` | Reviewers need orientation, then the diff | Agents still dump essays or skip UI shots |
| 2026-09-08 | No PR template in the scaffold | Templates pad; the rule is proportional copy | Teams keep shipping empty template sections anyway |

## Open questions

- Whether a later optional example PR body (one docs PR, one UI PR) would help more than it would be copied as boilerplate.
