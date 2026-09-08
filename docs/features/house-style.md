# Feature: House style

## Purpose

Give a product one living prose file so agents stop improvising spelling, dates, and punctuation – and so a human can set the rules once and extend them.

## How it should work

- [`HOUSE_STYLE.md`](../../HOUSE_STYLE.md) is the contract for **this** product. Agents load it every session, with `AGENTS.md` and `PROJECT_RULES.md`.
- Starters live in [`docs/house-style/`](../house-style/): `uk.md` (en-GB) and `general.md` (en-US). They are generic; they do not carry Canon product notes.
- Apply copies the chosen starter **into** `HOUSE_STYLE.md` (`--house-style=uk|general`, default **uk**). It does not copy this repo’s living file.
- It applies to **every prose surface** (docs, UI copy, errors, PRs, commits, comments, chat).
- Identifiers, APIs, filenames, and library names stay in ecosystem English (usually American: `color`, `behavior`). User-facing strings inside code still follow the house style.
- Regional overrides live in the living file (a table, not a second doc).
- Restyle is **forward-only** unless the human asks for a sweep. Cheap nits in a file already being edited are in bounds.

Chat apply: Fetch & apply asks “uk or general (default uk)”. Saying **uk** or “use defaults” is enough. Terminal: `--house-style=uk`. Later: `cp docs/house-style/uk.md HOUSE_STYLE.md`.

## Non-goals

- No linter or CI gate that fails PRs on `e.g.` vs `eg`.
- No Cursor-only rule file; Markdown is the baseline.
- No mass rewrite of existing Canon docs in the PR that introduces this file.
- Not a full publisher style guide (legal citations, news headlines, etc.).
- No `.example` suffix – agents would skip those files; starters are named profiles copied to a stable path.

## Edge cases & failure modes

- Restyling identifiers (`colour` as a CSS property, `organise` as a function) – forbidden; that breaks APIs.
- Keeping a parallel copy in `docs/house-style/` and editing both – starters are snapshots; only the root file is live.
- `--force` overwriting a product’s extended `HOUSE_STYLE.md` from the starter (not from Canon’s living file). Expected; confirm on TTY.
- Silent repo-wide rewrite after a one-line style tweak.
- Host chat rules that fight this file: follow the stricter rule and call out the conflict.

## Decisions

| Date | Decision | Why | Revisit when |
|------|----------|-----|--------------|
| 2026-09-08 | Always-on load, not “when writing docs” | Prose is most of what agents emit; a sometimes-loaded file gets skipped | Load cost or conflicts become noise |
| 2026-09-08 | Starters separate from the living file; apply copies `uk.md` or `general.md` | Product notes in Canon’s `HOUSE_STYLE.md` must not land in other products | Adopters want a third profile |
| 2026-09-08 | `--house-style=uk` default, not `.example` files | One live path; Fetch & apply can ask once | Default should be general for a more US-centric kit |
| 2026-09-08 | Serial comma; `-ise`; spaced en dashes; `eg` / `ie` without dots | Author ask, plus a comma rule that prevents list misreads | Author drops the serial comma or prefers Oxford `-ize` |
| 2026-09-08 | No CI spellcheck | Style is agent guidance; a gate would be noisy and locale-blind | A cheap, scoped check exists that does not punish identifiers |

## Open questions

- Serial comma vs a stricter “no Oxford comma” UK-news habit.
- Oxford `-ize` vs newspaper `-ise` (uk starter uses `-ise`).
- Whether commit subjects should stay in the repo’s existing tense/style even when the body follows this file.
