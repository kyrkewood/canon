# Canon

<p align="center">
  <img src="docs/canon-logo.svg" alt="Canon" width="160" />
</p>

**Canonical baseline for building with AI agents – rules, standards, and CI with enough firepower to enforce them.**

**Agents:** works with Cursor, Claude Code, Codex, Lovable, or anything that can edit a project and follow Markdown — not tied to one AI vendor.  
**Hosting / CI:** GitHub is the **default** (Actions + `gh` + PR-to-`main`). Other forges are fine if you keep the same shape: remote → branch → merge request → merge-blocking checks.

You get:

1. **Agent instructions** so the AI behaves like a careful engineer  
2. **Engineering standards** (security, accessibility, AI integration, architecture)  
3. **CI gates from day one** (GitHub Actions templates; adapt elsewhere if needed)  

**New to all this?** Start here → [`ADOPT.md`](ADOPT.md) (includes a copy-paste “fetch and apply” prompt).

**Comfortable in a terminal?** Use the 60-second start below.

License: [MIT](LICENSE).

---

## Who this is for

- Starting a **new** product and want a sane baseline  
- Adding structure to an **existing** project  
- Using **AI coding agents** and wanting them guided, not freestyling  
- People who **don’t know Git** but can paste a prompt into an AI tool  

---

## Fastest start (prompt-only)

1. Open your project in Cursor / Claude Code / Codex / Lovable (or similar).  
2. Paste the prompt from [`ADOPT.md`](ADOPT.md) (section **Fetch & apply**).  
3. Answer its short setup questions (or say “use defaults”).  
4. When it finishes, say: *Walk me through CANON_NEXT_STEPS.md in plain language.*

That’s it for the install. The next-steps file lists the few human clicks (usually GitHub settings).

---

## 60-second start (terminal)

### 1. Get Canon

```bash
git clone https://github.com/kyrkewood/canon.git
cd canon
```

### 2. Apply it to your project

```bash
./scaffold/apply.sh ~/projects/my-app
```

Existing project:

```bash
./scaffold/apply.sh /path/to/your-repo
```

With a UI (accessibility CI on):

```bash
./scaffold/apply.sh /path/to/your-repo --with-ui
```

Already have some of these files? Add `--force` only if you intend to overwrite them.

### 3. Finish the tiny checklist

Open `CANON_NEXT_STEPS.md` in the target project. Delete it when you’re done.

---

## What you get

| Piece | Purpose |
|-------|---------|
| `AGENTS.md` | How the coding agent should work (verify delivery, lean PRs, etc.) |
| `PROJECT_RULES.md` | Index of engineering non‑negotiables |
| `SECURITY.md` | Secrets, encryption, OWASP-oriented checks, privacy/logging |
| `ACCESSIBILITY.md` | WCAG targets and UI rules |
| `AI_INTEGRATION.md` | APIs / MCP / agent-friendly design |
| `ARCHITECTURE.md` | Short living map of *this* product (you fill it in) |
| `.github/workflows/*` | Secrets scan, dependency review, SAST, quality (+ a11y if UI) |

**Rules without CI are wishes.** Canon installs merge-blocking workflows when your host supports them.

---

## Using it day to day

1. Open the project in your coding agent.  
2. Standing instruction: *Follow AGENTS.md and PROJECT_RULES.md.* (Many tools auto-read `AGENTS.md`.)  
3. When work touches security, UI, or APIs, also load the matching domain doc.  
4. Keep change summaries **short** (1–3 bullets). For hard changes, a short literate walkthrough — not an essay. See `AGENTS.md`.

You mostly **don’t edit Canon itself** for each product. You apply it, fill product-specific blanks, and ship.

---

## After apply — the only steps you can’t skip

Printed again in `CANON_NEXT_STEPS.md`:

1. **GitHub remote** — `gh repo create … --source=. --remote=origin` (or `apply.sh --github`)  
2. **Baseline PR to `main`** — branch → push → `gh pr create` (or `--open-pr`); do not stop at local commits; do not auto-merge  
3. **Match CI to your toolchain** — e.g. `npm run lint` / `typecheck` / `test`, or edit `quality.yml`  
4. **Fill product blanks** in `SECURITY.md` and `ARCHITECTURE.md` (others if relevant)  
5. **Protect `main`** — Dependency graph + required status checks  
6. **Delete** `CANON_NEXT_STEPS.md` after the baseline PR is merged  

Longer optional checklist: `CANON_CHECKLIST.md` (from `scaffold/PROJECT_CREATION.md`).

### Credit (optional)

If you’re willing, link back from your project README — it helps others find Canon:

```markdown
Baseline from [Canon](https://github.com/kyrkewood/canon).
```

Or apply with `--credit` to append that line. Not required; skip for private/internal repos.

---

## Apply script options

```bash
./scaffold/apply.sh --help
```

| Flag | Meaning |
|------|---------|
| `--stack=node\|python\|none` | Prefill `quality.yml` (default: auto-detect) |
| `--with-ui` | Accessibility workflow active (you still wire axe) |
| `--force` | Overwrite existing canon files |
| `--credit` | Append the Canon credit line to `README.md` |
| `--github[=owner/name]` | Ensure git repo + GitHub `origin` (`gh repo create` if needed) |
| `--public` | With `--github`, create a public repo (default private) |
| `--open-pr` | Branch, commit, push, and open the baseline PR to `main` |

---

## What’s in this repo (map)

```
ADOPT.md                  ← start here if you only use AI chat
README.md                 This file
LICENSE                   MIT
docs/canon-logo.svg       Logo source (vector)
docs/canon-logo.png       Raster export
docs/canon-social.svg     Social preview source (1280×640)
docs/canon-social.png     Social preview export
AGENTS.md                 Agent workflow
PROJECT_RULES.md          Engineering index
SECURITY.md               Security & privacy
ACCESSIBILITY.md          Accessibility
AI_INTEGRATION.md         AI / API / MCP
ARCHITECTURE.md           Product architecture template
scaffold/
  apply.sh                Terminal apply
  PROJECT_CREATION.md     Full creation checklist
  ci/                     Workflow templates
```

---

## Improving Canon

This repo is the **source** of the baseline. Change standards here, then re-apply to products with `--force` when you intentionally want updates (review diffs first — force overwrites).

---

## License

[MIT](LICENSE) — free to use, copy, modify, and ship in your own products. Keep the copyright notice.
