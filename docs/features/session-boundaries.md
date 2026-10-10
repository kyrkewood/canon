# Feature: Session boundaries

## Purpose

Long chats degrade agent output. Agents recommend a fresh session at objective boundaries, with a resume prompt, so the user gets better results without tracking context themselves.

## How it should work

- `AGENTS.md` carries a three-line rule (always loaded); the template and per-tool steps live in `docs/session-handoff.md` (loaded only when the rule fires).
- Triggers are observable: a PR was just opened, the user switches to an unrelated capability, or the agent catches itself re-asking settled questions or contradicting an earlier decision.
- One nudge per boundary, never mid-task. Fresh session preferred over compaction.
- The agent prints a paste-ready resume prompt and first ensures unwritten state is saved.

## Non-goals

- No token or context-window measurement; agents cannot reliably see it.
- No tool-specific automation (hooks, status lines).
- Never blocks or refuses to continue; the user decides.

## Edge cases & failure modes

- Nagging: repeating the nudge, or firing on adjacent follow-ups the user wants in context.
- Resetting with decisions only in chat; the handoff lists them under *Not yet written down*.
- Per-tool commands drift; only `/clear` for Claude Code is named, the rest stay generic.

## Decisions

| Date | Decision | Why | Revisit when |
|------|----------|-----|--------------|
| 2026-10-10 | Always-on rule plus on-demand handoff file, not opt-in | Opt-in is undiscoverable; the rule is the discovery mechanism | If the rule costs noticeable context or never fires |
| 2026-10-10 | Fresh session over compaction | Compaction keeps the agent's own errors | If tools offer lossless context resets |
| 2026-10-10 | No "context feels full" trigger | Agents cannot measure it | If harnesses expose usage to the agent |

## Open questions

- Should a hook or status line complement this where the harness supports it?
