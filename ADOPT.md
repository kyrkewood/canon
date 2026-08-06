# Adopt Canon (even if you barely know Git)

Canon is a **starter kit of rules + safety checks** for building software with AI.  
You do not need to be a developer to get most of the benefit — you need an AI coding tool and a willingness to paste a prompt.

## Tiny glossary

| Word | Plain meaning |
|------|----------------|
| **Project / folder** | The place your app’s files live on your computer or in the cloud |
| **Repo (repository)** | That project, plus history of changes (usually on GitHub) |
| **GitHub** | Default place repos and automated checks live (Canon’s reference host) |
| **Agent** | The AI that edits files for you (Cursor, Claude Code, Codex, etc.) |
| **CI** | Robots that run checks on every change (secrets, tests, security) |
| **Apply Canon** | Copy Canon’s rules and CI into *your* project |

You are not “learning Git.” You are giving your AI a constitution and a seatbelt.

Canon is **not** locked to one AI product. It **does** ship GitHub Actions + `gh` as the default remote/CI path; use another forge if you prefer, as long as baseline still lands via merge request with blocking checks.

---

## Pick your path

### A) I only chat with an AI (recommended if you’re unsure)

1. Open your app project in your tool (or start a new one).
2. Paste the **Fetch & apply** prompt below.
3. Answer the short questions it asks (UI, GitHub remote/PR, visibility, credit) — or say “use defaults.”
4. When it finishes, say: **“Walk me through CANON_NEXT_STEPS.md in plain language.”**
5. Do the few clicks it asks for (usually GitHub settings).

### B) I can run a terminal command

Follow the [README](README.md) 60-second start (`git clone` → `./scaffold/apply.sh`).

---

## Fetch & apply prompt (copy-paste)

Works in **Cursor**, **Claude Code**, **Codex**, and similar tools that can browse the web and edit files. Paste this as-is:

```text
Fetch and apply Canon to this project.

Canon source: https://github.com/kyrkewood/canon

Before changing files, ask me these (one short message; defaults in parentheses):
1. User-facing UI? → --with-ui (no)
2. Stack if unclear: node / python / leave quality.yml for me (auto-detect)
3. Create/link GitHub remote + open baseline PR to main? → --github / --open-pr (yes, unless I say local-only)
4. Repo visibility if creating: private / public (private)
5. GitHub owner/name if creating (ask; don’t invent an org)
6. Add README credit line? → --credit (ask; default no)
7. Host “don’t commit unless asked” vs Canon delivery → Route A prefer delivery / Route B ask-before-commit (ask; default A if unsure)

Do this after I answer (or after I say “use defaults”):
1. Get the Canon files (clone, sparse checkout, or download — your choice).
2. Prefer running: scaffold/apply.sh <this-project-root> with the flags we agreed.
   If you cannot run the script, copy the docs + scaffold/ci/*.yml into .github/workflows/
   and follow CANON_NEXT_STEPS / PROJECT_CREATION manually with the same choices.
3. After apply, create or link a remote and open a PR to main (GitHub default) unless I opted out (Route B or local-only);
   under Route A do not stop at local commits; do not auto-merge.
4. Create or update CANON_NEXT_STEPS.md with only what I still must do — include section 7b (Route A/B) and record my choice.
5. Summarize in 5 bullets what you installed and what I should do next.
6. Do not invent secrets. Do not disable CI gates. Keep explanations short.

When done, wait for me — then walk me through CANON_NEXT_STEPS.md step by step
in plain language (assume I don’t know GitHub jargon).
```

### Shorter variant (if the tool hates long prompts)

```text
Apply https://github.com/kyrkewood/canon to this project. First ask me about:
UI (--with-ui), GitHub remote+PR (--github/--open-pr), private vs public,
repo name, README credit (--credit), and delivery Route A vs ask-before-commit Route B.
Then run apply.sh (or copy docs/CI) with those choices. Record the route in
CANON_NEXT_STEPS. Explain CANON_NEXT_STEPS.md simply when done.
```

---

## Tool notes

| Tool | How to use Canon |
|------|------------------|
| **Cursor** | Open the project → Agent chat → paste Fetch & apply. Apply installs `.cursor/rules/agents.mdc` → `AGENTS.md`. Route A + ask-first conflict: optionally add `.cursor/rules/canon-delivery.mdc` (see Canon repo); Route B: do not. |
| **Claude Code** | In the project directory → paste Fetch & apply. Apply installs `CLAUDE.md` → `AGENTS.md`. |
| **Codex** (or similar CLI agents) | Same apply path; many auto-read `AGENTS.md` natively. |
| **Lovable** / browser app builders | Paste Fetch & apply; if there’s no shell, ask it to **create the same Markdown files and GitHub workflow files in the project**. Then connect GitHub and enable checks if the host allows. |
| **ChatGPT / Claude web (no file access)** | Canon can’t install itself. Use a tool that can edit your project, or have someone run `apply.sh` for you. |

Canon is **not** Cursor-only. Any agent that can read `AGENTS.md` can use it.  
GitHub is the **default** place for remotes and CI; if you use another host, keep the same delivery loop.

---

## What “done” looks like

- Your project has `AGENTS.md` + the other Canon docs  
- CI workflows exist (`.github/workflows/` on GitHub, or equivalent elsewhere)  
- Baseline landed via **PR/MR to `main`**, not only local commits  
- You finished / deleted `CANON_NEXT_STEPS.md`  
- Your agent is told to follow those docs on every task  

If your builder **doesn’t support GitHub Actions**, you still get the agent docs — add merge-blocking CI when you have a real host.

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
