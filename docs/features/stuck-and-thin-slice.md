# Feature: Thin slice & stuck handling

## Purpose

Standing orders so agents ship a narrow working path first, stop thrashing when stuck, and never destroy shared git history to “get unstuck.”

## How it should work

- Prefer one end-to-end tracer bullet before broadening.
- When scope is ambiguous, ask once for bounds (paths, interface changes).
- After a few failed attempts at the same approach, hand back the wheel.
- Fix forward when the mistake is small; roll back a tangled slice and retry cleanly.
- No force-push to default branches, no rewriting shared history, no deleting others’ work without an ask.

See `AGENTS.md` — Thin slice first; When stuck / when wrong.

## Non-goals

- Not a multi-agent orchestration framework.
- Not a hard attempt counter in tooling — judgment call, then ask.

## Edge cases & failure modes

- Silently widening scope instead of asking for bounds.
- Stacking compensatory patches on a bad slice instead of rolling back.
- Narrating host “don’t commit” conflicts as hesitation (see delivery conflict rule).

## Decisions

| Date | Decision | Why | Revisit when |
|------|----------|-----|--------------|
| 2026-08-01 | Short AGENTS sections + smell test; feature doc for lasting behavior | Dogfood feature-docs rule | If agents still thrash in the field |

## Open questions

- None yet.
