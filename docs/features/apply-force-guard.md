# Feature: apply --force guard

## Purpose

Prevent accidental clobber of product-edited Canon files when re-applying.

## How it should work

- `--force` alone: print unified diffs for files that would be overwritten, write nothing, exit non-zero.
- `--force --yes`: overwrite as before.
- `--yes` without `--force`: error.

## Non-goals

- No interactive TTY prompts (agents/CI need flags).
- Does not merge product edits — human reviews the plan diff.

## Decisions

| Date | Decision | Why | Revisit when |
|------|----------|-----|--------------|
| 2026-08-06 | `--force` = plan; `--force --yes` = clobber | Footgun; keeps automation non-interactive | — |
