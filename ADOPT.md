# Adopt Canon (even if you barely know Git)

Canon is a **starter kit of rules + safety checks** for building software with AI.  
You do not need to be a developer to get most of the benefit — you need an AI coding tool and a willingness to paste a prompt.

## Tiny glossary

| Word | Plain meaning |
|------|----------------|
| **Project / folder** | The place your app’s files live on your computer or in the cloud |
| **Repo (repository)** | That project, plus history of changes (usually on GitHub) |
| **GitHub** | A website that stores repos and can run automatic checks |
| **Agent** | The AI that edits files for you (Cursor, Claude Code, Codex, etc.) |
| **CI** | Robots that run checks on every change (secrets, tests, security) |
| **Apply Canon** | Copy Canon’s rules and CI into *your* project |

You are not “learning Git.” You are giving your AI a constitution and a seatbelt.

---

## Pick your path

### A) I only chat with an AI (recommended if you’re unsure)

1. Open your app project in your tool (or start a new one).
2. Paste the **Fetch & apply** prompt below.
3. When it finishes, say: **“Walk me through CANON_NEXT_STEPS.md in plain language.”**
4. Do the few clicks it asks for (usually on GitHub).

### B) I can run a terminal command

Follow the [README](README.md) 60-second start (`git clone` → `./scaffold/apply.sh`).

---

## Fetch & apply prompt (copy-paste)

Works in **Cursor**, **Claude Code**, **Codex**, and similar tools that can browse the web and edit files. Paste this as-is:

```text
Fetch and apply Canon to this project.

Canon source: https://github.com/kyrkewood/canon

Do this:
1. Get the Canon files (clone, sparse checkout, or download — your choice).
2. Prefer running: scaffold/apply.sh <this-project-root>
   - Use --with-ui if this project has a user-facing UI.
   - Detect Node vs Python if possible; otherwise leave quality.yml for us to wire.
3. If you cannot run the script, copy into this project root:
   AGENTS.md, PROJECT_RULES.md, SECURITY.md, ACCESSIBILITY.md,
   AI_INTEGRATION.md, ARCHITECTURE.md
   and copy scaffold/ci/*.yml into .github/workflows/
4. Create or update CANON_NEXT_STEPS.md with only what I still must do.
5. Summarize in 5 bullets what you installed and what I should do next.
6. Do not invent secrets. Do not disable CI gates. Keep explanations short.

When done, wait for me — then walk me through CANON_NEXT_STEPS.md step by step
in plain language (assume I don’t know GitHub jargon).
```

### Shorter variant (if the tool hates long prompts)

```text
Apply https://github.com/kyrkewood/canon to this project (run scaffold/apply.sh
if possible, else copy docs + .github/workflows). Then explain CANON_NEXT_STEPS.md
to me like I’m new. Keep it short.
```

---

## Tool notes

| Tool | How to use Canon |
|------|------------------|
| **Cursor** | Open the project → Agent chat → paste Fetch & apply. `AGENTS.md` is usually auto-read later. |
| **Claude Code** | In the project directory → paste Fetch & apply. Say “follow AGENTS.md and PROJECT_RULES.md” if needed. |
| **Codex** (or similar CLI agents) | Same as Claude Code — paste Fetch & apply in the project workspace. |
| **Lovable** / browser app builders | Paste Fetch & apply; if there’s no shell, ask it to **create the same Markdown files and GitHub workflow files in the project**. Then connect GitHub and enable checks if the host allows. |
| **ChatGPT / Claude web (no file access)** | Canon can’t install itself. Use a tool that can edit your project, or have someone run `apply.sh` for you. |

Canon is **not** Cursor-only. Any agent that can read `AGENTS.md` and follow links to the other docs can use it.

---

## What “done” looks like

- Your project has `AGENTS.md` + the other Canon docs  
- `.github/workflows/` has the CI files (if your host supports GitHub Actions)  
- You finished / deleted `CANON_NEXT_STEPS.md`  
- Your agent is told to follow those docs on every task  

If your builder **doesn’t support GitHub Actions**, you still benefit from the docs guiding the agent — add CI when you move to a normal GitHub repo.

---

## Day-to-day prompt (after Canon is applied)

```text
Follow AGENTS.md and PROJECT_RULES.md. Load SECURITY.md / ACCESSIBILITY.md /
AI_INTEGRATION.md only when the task touches those areas. Keep PRs and summaries short.
```

Save that as a standing instruction / project rule in your tool if it has one.

---

## Stuck?

1. Open [`README.md`](README.md) for the terminal path.  
2. Open [`scaffold/PROJECT_CREATION.md`](scaffold/PROJECT_CREATION.md) for the long checklist.  
3. Ask your agent: *“What did Canon install, and what’s still missing? Use CANON_NEXT_STEPS.md.”*
