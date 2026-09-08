# House style

Living prose rules for this product. Set them once in this file; extend it rather than scattering notes.

**Locale:** en-US, with regional overrides below.  
**Agents:** follow this file on every prose surface. Do not restyle untouched files unless asked.

This is the **general** profile (US spelling, dotted `e.g.` / `i.e.`, ISO dates in technical contexts). To use it, copy this file over `HOUSE_STYLE.md` in the repo root, then keep editing `HOUSE_STYLE.md` only.

---

## In scope / out of scope

**Follow this file for** UI copy, docs, README, errors, emails, PR titles and bodies, commit messages, code comments, and chat with the human.

**Leave alone:**

- Identifiers, APIs, JSON keys, filenames, and protocol names – keep the form the language, library, or ecosystem already uses (usually American English: `color`, `behavior`, `organize`)
- Language keywords, import paths, and third-party names
- Quoted output from other systems
- Legal or trademark forms of names

User-facing strings *inside* code follow this file. The identifier next to them does not.

## Locale and overrides

Default: **en-US**.

When a surface is explicitly another locale, change only the rows in this table. Everything else stays.

| Topic | en-US (default) | en-GB |
|-------|-----------------|-------|
| Dates in prose | September 1, 2026 | 1 September 2026 |
| Compact dates | Prefer ISO | 1.9.26 |
| Spelling | organize, color, behavior, center | organise, colour, behaviour, centre |
| Times | 9:00 am | 09:00 (24-hour) |

ISO `2026-09-01` is always valid for filenames, logs, APIs, and tables. Do not use `9/1/2026` even in en-US; it is ambiguous.

## Dates

- Prose: `September 1, 2026` – no ordinal (`1st`)
- Technical: `2026-09-01`
- Never `1.9.26` or `9/1/26` unless an en-GB override is in force and the surface is tight UI

## Spelling (en-US)

- `-ize` (organize, standardize)
- `-or` (color, behavior)
- `-er` (center, meter) except when the token is an identifier that already differs
- **program** for software and for events

## Dashes

Use a spaced en dash – like this – or split into two sentences.

Do not use em dashes.

Hyphens stay for compounds (merge-blocking, day-one).

## e.g. and i.e.

Write `e.g.` and `i.e.` with dots. Use commas around them when they sit mid-sentence:

- Save a copy, e.g. a CSV.
- The default, i.e. Route A, is the PR loop.

Do not write `eg`, `ie`, `eg.`, or `ie.`.

## Commas and lists

Use the serial (Oxford) comma: "lint, typecheck, and test".

## Quotes

Straight double quotes in prose ("like this"). Single quotes for quotes nested inside, and in code as the language requires.

No curly quotes in source files.

## Headings

Sentence case: "How it should work", not "How It Should Work".

## Voice

- UI and errors: you / your
- Docs about the product: we / the product name
- Contractions are fine
- Prefer short sentences over stacked clauses

## Numbers and times

- Spell one to nine in running prose; use digits for 10+. Exception: dates, versions, measurements, and counts in UI
- 12-hour times: 9:00 am (lowercase am/pm, space before)
- No extra space in `10%` or `$12`

## Change policy

1. Edit `HOUSE_STYLE.md` (the copy in the repo root). Do not start a second house-style doc.
2. New rules are additive. To reverse a rule, replace it there and note it in `docs/features/house-style.md`.
3. Apply going forward. Do not sweep the repo to match a tweak unless asked.
4. If you are already editing a file, fix cheap nits there.

## Product-specific notes

_Add product vocabulary, banned phrases, and extra locale rows here._
