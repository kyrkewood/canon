# Feature: Agent discovery pointers

## Purpose

Ensure Cursor and Claude Code load Canon’s standing instructions. `AGENTS.md` stays the single source of truth; thin pointer files match each tool’s discovery convention.

## How it should work

- `apply.sh` copies `CLAUDE.md` and `.cursor/rules/agents.mdc` into the target.
- Both files only redirect to `AGENTS.md` (`CLAUDE.md` via `@AGENTS.md`) — no forked rules. `AGENTS.md` decides what else loads.
- Codex-style tools that already read `AGENTS.md` need no pointer.
- Optional Route A Cursor rule (`canon-delivery.mdc`) remains separate and is **not** applied by default.

## Non-goals

- Not a second rulebook.
- Not vendor lock-in — pointers exist so tools find the shared Markdown.

## Edge cases & failure modes

- Editing rules only in `CLAUDE.md` / `.mdc` and drifting from `AGENTS.md`.
- Copying `canon-delivery.mdc` into Route B products.

## Decisions

| Date | Decision | Why | Revisit when |
|------|----------|-----|--------------|
| 2026-10-10 | `AGENTS.md` is a small master doc (under 4 KB, checked by `verify.sh`); situational detail moves to `docs/agent/` and loads on demand | Keep always-on context small without losing rules | Agents miss rules that moved out |
| 2026-08-06 | Thin pointers + honest README discovery table | Real gap for Cursor/Claude Code | Tools change auto-read conventions |

## Open questions

- Whether other tools gain first-class pointer filenames worth adding later.
