# Feature docs

Living, human-readable notes for **capabilities** in this product — purpose, how it should behave, edge cases, and decisions worth remembering.

Not a second codebase. Not a novel. One short Markdown file per meaningful capability.

## When to create or update

**Create** when you ship a new capability (user-facing or internal) that someone will need to evolve later.  
**Update** when behavior, contracts, or constraints change.  
**Skip** for tiny fixes, renames, and pure refactors with no behavior change.

If you’re unsure: if a future agent would guess wrong without this file, write it.

## Layout

```
docs/features/
  README.md           ← this file
  _TEMPLATE.md        ← copy me
  billing-invoices.md ← example name: kebab-case capability
```

Link important features from [`ARCHITECTURE.md`](../../ARCHITECTURE.md) (Key Flows / Building Blocks).

## Rules of thumb

- Prefer **decisions and behavior** over implementation tour.
- Record **edge cases** and **non-goals** — that’s where debt hides.
- Keep each file scannable in one screen when possible; link out for deep design.
- Stale docs are bugs: update in the same PR as the behavior change.
