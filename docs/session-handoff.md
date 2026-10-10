# Session handoff

Load this only when `AGENTS.md` → **Session boundaries** fires. Goal: better output from a clean context, with nothing lost.

## Why fresh beats compress

Compaction is the agent summarising its own context, so stale assumptions and half-settled decisions survive it. A new session that rebuilds from files (`AGENTS.md`, feature docs, the PR) starts clean. Suggest compaction only when there is a lot of unwritten state the user cannot easily restate.

## The nudge

Once per boundary, one sentence of reason, then offer the resume prompt:

> This looks like a good point for a fresh session — <reason>. Want a resume prompt to paste in?

## Resume prompt (agent prints it, user pastes it)

Before printing, make sure anything only in this chat is written down (feature doc, `CANON_NEXT_STEPS.md`, PR description) or listed under *Not yet written down*.

```text
Resume work on <product>. Follow AGENTS.md, PROJECT_RULES.md, and HOUSE_STYLE.md.

Done: <what shipped; branch / PR link>
State lives in: <feature doc, plan, PR>
Next: <the one next task>
Decisions still in force: <short list>
Not yet written down: <anything only in the old chat, or "none">
```

## Starting fresh

| Tool | How |
|------|-----|
| Claude Code | `/clear`, then paste (or `/compact` as the fallback) |
| Cursor, Codex, Lovable, others | Open a new chat / session, then paste |
