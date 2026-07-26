# Canon

**The starter kit for building products with coding agents — without reinventing the rules every time.**

Canon gives you:

1. **Agent instructions** so Cursor (or similar) behaves like a careful engineer  
2. **Clear engineering standards** (security, accessibility, AI integration, architecture)  
3. **CI gates from day one** so those standards are enforced, not just written down  

If you only do one thing: run the apply script on your project, open `CANON_NEXT_STEPS.md`, and finish the short list.

---

## Who this is for

- Starting a **new** product and want a sane baseline  
- Adding structure to an **existing** repo  
- Using **AI coding agents** and wanting them guided, not freestyling  

You do **not** need to be a platform engineer. If you can run one terminal command and click a few GitHub settings, you can use this.

---

## 60-second start

### 1. Get Canon

```bash
git clone https://github.com/kyrkewood/canon.git
cd canon
```

### 2. Apply it to your project

**New empty folder:**

```bash
./scaffold/apply.sh ~/projects/my-app
```

**Existing project (Node or Python auto-detected):**

```bash
./scaffold/apply.sh /path/to/your-repo
```

**Existing project with a UI (turns on accessibility CI):**

```bash
./scaffold/apply.sh /path/to/your-repo --with-ui
```

**Already have some of these files?** Add `--force` only if you intend to overwrite them.

### 3. Finish the tiny checklist

```bash
open ~/projects/my-app/CANON_NEXT_STEPS.md   # or just open the file in your editor
```

That file tells you exactly what to do next (wire scripts, fill a few blanks, push, turn on branch protection). Delete it when you’re done.

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

**Rules without CI are wishes.** Canon installs merge-blocking workflows so the important bar is mechanical.

---

## Using it day to day

1. Open the project in **Cursor** (or your agent of choice).  
2. Agents should pick up `AGENTS.md`. If not, say: *Follow AGENTS.md and PROJECT_RULES.md.*  
3. When work touches security, UI, or APIs, the agent should also open the matching domain doc.  
4. Keep PRs **short** (1–3 bullets). For hard changes, add a short literate walkthrough — not an essay. See `AGENTS.md`.

You mostly **don’t edit Canon itself** for each product. You apply it, fill product-specific blanks, and ship.

---

## After apply — the only steps you can’t skip

Printed again in `CANON_NEXT_STEPS.md`:

1. **Match CI to your toolchain** — e.g. `npm run lint` / `typecheck` / `test` exist, or edit `quality.yml`.  
2. **Fill product blanks** in `SECURITY.md` and `ARCHITECTURE.md` (others if relevant).  
3. **Push to GitHub** and enable Dependency graph + required status checks on `main`.  
4. **Delete** `CANON_NEXT_STEPS.md` when finished.

Longer optional checklist: `CANON_CHECKLIST.md` (copied from `scaffold/PROJECT_CREATION.md`).

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

---

## What’s in this repo (map)

```
AGENTS.md                 Agent workflow
PROJECT_RULES.md          Engineering index
SECURITY.md               Security & privacy
ACCESSIBILITY.md          Accessibility
AI_INTEGRATION.md         AI / API / MCP
ARCHITECTURE.md           Product architecture template
scaffold/
  apply.sh                ← start here
  PROJECT_CREATION.md     Full creation checklist
  ci/                     Workflow templates
```

---

## Improving Canon

This repo is the **source** of the baseline. Change standards here, then re-apply to products with `--force` when you intentionally want updates (review diffs first — force overwrites).

---

## License / ownership

Team baseline for products built from this scaffold. Add a license file if you publish it externally.
