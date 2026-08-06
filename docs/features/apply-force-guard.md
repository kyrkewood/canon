# Feature: apply --force guard

## Purpose

Prevent accidental clobber of product-edited Canon files when re-applying, while still surfacing drift.

## How it should work

**Without `--force`:** if a target file exists and differs from Canon, print a unified diff and skip overwrite (same idea as `git status` / chezmoi — show drift, don’t clobber).

**With `--force`:** print diffs for candidates, then:
- TTY: confirm `Overwrite …? [y/N]`
- Non-interactive / agents: require `--yes` (terraform `-auto-approve` / apt `-y` convention)

## Non-goals

- No merge of product edits into Canon templates — human reviews the diff.
- No prompting when stdin is not a TTY unless `--yes` is set.

## Decisions

| Date | Decision | Why | Revisit when |
|------|----------|-----|--------------|
| 2026-08-06 | `--force` + TTY confirm; `--yes` for agents | Matches common CLI convention; avoids silent clobber | — |
| 2026-08-06 | Diffs without `--force` when files differ | Drift visibility shouldn’t require a destructive flag | Noise if too verbose |
