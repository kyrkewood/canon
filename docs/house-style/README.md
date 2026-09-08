# House style examples

Starters to copy into `HOUSE_STYLE.md`. Agents follow the **root** file only.

| File | Profile |
|------|---------|
| [`uk.md`](uk.md) | en-GB – apply default (`--house-style=uk`) |
| [`general.md`](general.md) | en-US / general tech-docs (`--house-style=general`) |

This repo’s living file is [`../../HOUSE_STYLE.md`](../../HOUSE_STYLE.md) (uk starter plus Canon notes). Apply does **not** copy that file into products.

## Set once

1. Apply with `--house-style=uk` or `--house-style=general` (default **uk**).
2. Or later: `cp docs/house-style/uk.md HOUSE_STYLE.md` (or `general.md`).
3. Fill **Product-specific notes**. After that, only edit `HOUSE_STYLE.md`.

## Build on it

Add or replace rules in `HOUSE_STYLE.md`. New prose follows that file; do not sweep old docs unless asked.

## What it does not cover

Code identifiers and APIs stay in ecosystem English (usually American). See **In scope / out of scope** in the living file.
