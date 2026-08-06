#!/usr/bin/env bash
# Apply the canon baseline into a new or existing project.
# Usage: ./scaffold/apply.sh /path/to/project [options]
set -euo pipefail

CANON_CREDIT_LINE='Baseline from [Canon](https://github.com/kyrkewood/canon).'
CANON_BASELINE_BRANCH='chore/canon-baseline'

usage() {
  cat <<'EOF'
Apply canon (agent rules + engineering docs + CI) to a project.

Usage:
  ./scaffold/apply.sh <target-dir> [options]

Options:
  --force              Overwrite existing Canon files (shows diffs; confirms on a TTY)
  --yes                With --force, skip the confirm prompt (for agents/CI)
  --stack=node|python|none
                       Prefill quality.yml for that stack (default: auto-detect)
  --with-ui            Include accessibility CI as active (default: copy, keep dormant)
  --credit             Append a short Canon credit line to the target README.md
  --github[=owner/name]
                       Ensure git repo + GitHub remote (gh repo create if missing)
  --public             With --github, create a public repo (default: private)
  --open-pr            After apply: branch, commit, push, and open a PR to main
  -h, --help           Show this help

Examples:
  ./scaffold/apply.sh ~/projects/my-app
  ./scaffold/apply.sh . --stack=node --with-ui --github --open-pr
  ./scaffold/apply.sh ../new-thing --force                 # diffs + confirm on TTY
  ./scaffold/apply.sh ../new-thing --force --yes --credit  # agents/CI: no prompt

What it does:
  1. Creates the target folder if needed
  2. Copies AGENTS.md, PROJECT_RULES.md, and domain docs
  3. Copies GitHub Actions workflows into .github/workflows/
  4. Writes CANON_NEXT_STEPS.md (PR-to-main is required, not optional)
  5. Optional: --credit, --github, --open-pr
EOF
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CANON_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

TARGET=""
FORCE=0
FORCE_YES=0
STACK="auto"
WITH_UI=0
CREDIT=0
DO_GITHUB=0
GITHUB_REPO=""
GITHUB_VISIBILITY="private"
OPEN_PR=0
GH_BLOCKER=""

for arg in "$@"; do
  case "$arg" in
    -h|--help) usage; exit 0 ;;
    --force) FORCE=1 ;;
    --yes) FORCE_YES=1 ;;
    --with-ui) WITH_UI=1 ;;
    --credit) CREDIT=1 ;;
    --public) GITHUB_VISIBILITY="public" ;;
    --open-pr) OPEN_PR=1 ;;
    --github) DO_GITHUB=1 ;;
    --github=*)
      DO_GITHUB=1
      GITHUB_REPO="${arg#*=}"
      ;;
    --stack=*) STACK="${arg#*=}" ;;
    -*)
      echo "Unknown option: $arg" >&2
      usage >&2
      exit 1
      ;;
    *)
      if [[ -n "$TARGET" ]]; then
        echo "Unexpected argument: $arg" >&2
        usage >&2
        exit 1
      fi
      TARGET="$arg"
      ;;
  esac
done

if [[ -z "$TARGET" ]]; then
  usage >&2
  exit 1
fi

case "$STACK" in
  auto|node|python|none) ;;
  *)
    echo "--stack must be node, python, none, or auto" >&2
    exit 1
    ;;
esac

if [[ "$FORCE_YES" -eq 1 && "$FORCE" -ne 1 ]]; then
  echo "--yes requires --force" >&2
  exit 1
fi

mkdir -p "$TARGET"
TARGET="$(cd "$TARGET" && pwd)"

# Print unified diff for an existing dest vs Canon src (or a note if generated).
show_file_diff() {
  local dest="$1"
  local src="${2:-}"
  local rel="${dest#"$TARGET"/}"
  echo "--- $rel (local vs Canon) ---"
  if [[ -n "$src" && -f "$src" ]]; then
    diff -u "$dest" "$src" || true
  else
    echo "  (generated/checklist — content may be regenerated on overwrite)"
  fi
  echo
}

copy_file() {
  local src="$1"
  local dest="$2"
  local rel="${dest#"$TARGET"/}"

  if [[ ! -e "$dest" ]]; then
    mkdir -p "$(dirname "$dest")"
    cp "$src" "$dest"
    echo "  wrote: $rel"
    return 0
  fi

  if cmp -s "$src" "$dest" 2>/dev/null; then
    echo "  skip (unchanged): $rel"
    return 0
  fi

  # Exists and differs
  if [[ "$FORCE" -ne 1 ]]; then
    # Surface drift without requiring --force (like git status / chezmoi).
    show_file_diff "$dest" "$src"
    echo "  skip (differs): $rel  (pass --force to overwrite after confirm)"
    return 0
  fi

  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
  echo "  wrote (overwrote): $rel"
}

# List of existing paths that --force would clobber (for confirm). Returns count via stdout last line... use global.
FORCE_CANDIDATES=0

count_force_candidates() {
  FORCE_CANDIDATES=0
  local dest rel src
  for rel in \
    AGENTS.md PROJECT_RULES.md SECURITY.md ACCESSIBILITY.md AI_INTEGRATION.md ARCHITECTURE.md \
    CLAUDE.md \
    .cursor/rules/agents.mdc \
    docs/features/README.md docs/features/_TEMPLATE.md \
    .github/workflows/secrets-scan.yml \
    .github/workflows/dependency-review.yml \
    .github/workflows/sast.yml \
    .github/workflows/quality.yml \
    .github/workflows/accessibility.yml \
    CANON_CHECKLIST.md
  do
    dest="$TARGET/$rel"
    [[ -e "$dest" ]] || continue
    case "$rel" in
      .github/workflows/quality.yml|.github/workflows/accessibility.yml|CANON_CHECKLIST.md)
        FORCE_CANDIDATES=$((FORCE_CANDIDATES + 1))
        show_file_diff "$dest" ""
        ;;
      .github/workflows/*)
        src="$CANON_ROOT/scaffold/ci/${rel##*/}"
        if [[ -f "$src" ]] && ! cmp -s "$src" "$dest" 2>/dev/null; then
          FORCE_CANDIDATES=$((FORCE_CANDIDATES + 1))
          show_file_diff "$dest" "$src"
        elif [[ -f "$src" ]]; then
          : # unchanged
        else
          FORCE_CANDIDATES=$((FORCE_CANDIDATES + 1))
          show_file_diff "$dest" ""
        fi
        ;;
      .cursor/rules/agents.mdc)
        src="$CANON_ROOT/.cursor/rules/agents.mdc"
        [[ -f "$src" ]] || continue
        if ! cmp -s "$src" "$dest" 2>/dev/null; then
          FORCE_CANDIDATES=$((FORCE_CANDIDATES + 1))
          show_file_diff "$dest" "$src"
        fi
        ;;
      CLAUDE.md)
        src="$CANON_ROOT/CLAUDE.md"
        [[ -f "$src" ]] || continue
        if ! cmp -s "$src" "$dest" 2>/dev/null; then
          FORCE_CANDIDATES=$((FORCE_CANDIDATES + 1))
          show_file_diff "$dest" "$src"
        fi
        ;;
      *)
        src="$CANON_ROOT/$rel"
        [[ -f "$src" ]] || continue
        if ! cmp -s "$src" "$dest" 2>/dev/null; then
          FORCE_CANDIDATES=$((FORCE_CANDIDATES + 1))
          show_file_diff "$dest" "$src"
        fi
        ;;
    esac
  done
}

confirm_force() {
  count_force_candidates
  if [[ "$FORCE_CANDIDATES" -eq 0 ]]; then
    echo "No differing Canon files to overwrite."
    return 0
  fi
  echo "Force will overwrite $FORCE_CANDIDATES differing file(s) (diffs above)."
  if [[ "$FORCE_YES" -eq 1 ]]; then
    echo "  --yes: skipping confirm."
    return 0
  fi
  if [[ -t 0 ]]; then
    local ans=""
    read -r -p "Overwrite with Canon versions? [y/N] " ans
    if [[ "$ans" =~ ^[Yy]$ ]]; then
      return 0
    fi
    echo "Aborted. Re-run with --force when ready (or --force --yes for non-interactive)." >&2
    exit 1
  fi
  echo "Non-interactive terminal: re-run with --force --yes to overwrite without a prompt." >&2
  exit 1
}

detect_stack() {
  if [[ -f "$TARGET/package.json" ]]; then
    echo "node"
  elif [[ -f "$TARGET/pyproject.toml" || -f "$TARGET/requirements.txt" || -f "$TARGET/Pipfile" ]]; then
    echo "python"
  else
    echo "none"
  fi
}

if [[ "$STACK" == "auto" ]]; then
  STACK="$(detect_stack)"
fi

echo "Applying canon → $TARGET"
echo "  stack: $STACK"
echo "  ui a11y workflow: $([[ "$WITH_UI" -eq 1 ]] && echo active || echo dormant)"
echo

if [[ "$FORCE" -eq 1 ]]; then
  confirm_force
fi

echo "Docs"
DOCS=(
  AGENTS.md
  PROJECT_RULES.md
  SECURITY.md
  ACCESSIBILITY.md
  AI_INTEGRATION.md
  ARCHITECTURE.md
)
for doc in "${DOCS[@]}"; do
  copy_file "$CANON_ROOT/$doc" "$TARGET/$doc"
done

# Agent discovery pointers (tool-specific entrypoints → AGENTS.md)
copy_file "$CANON_ROOT/CLAUDE.md" "$TARGET/CLAUDE.md"
copy_file "$CANON_ROOT/.cursor/rules/agents.mdc" "$TARGET/.cursor/rules/agents.mdc"

# Feature-doc kit (directory)
mkdir -p "$TARGET/docs/features"
copy_file "$CANON_ROOT/docs/features/README.md" "$TARGET/docs/features/README.md"
copy_file "$CANON_ROOT/docs/features/_TEMPLATE.md" "$TARGET/docs/features/_TEMPLATE.md"

echo
echo "CI workflows"
WF_DEST="$TARGET/.github/workflows"
mkdir -p "$WF_DEST"

for wf in secrets-scan.yml dependency-review.yml sast.yml; do
  copy_file "$CANON_ROOT/scaffold/ci/$wf" "$WF_DEST/$wf"
done

# quality.yml — stack-aware
QUALITY_DEST="$WF_DEST/quality.yml"
if [[ -e "$QUALITY_DEST" && "$FORCE" -ne 1 ]]; then
  echo "  skip (exists): .github/workflows/quality.yml  (pass --force to regenerate after confirm)"
else
  case "$STACK" in
    node)
      cat > "$QUALITY_DEST" <<'EOF'
# Quality — lint, typecheck, unit tests (required)
name: Quality

on:
  push:
    branches: [main, master]
  pull_request:

permissions:
  contents: read

jobs:
  quality:
    name: Lint, types, tests
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: "22"
          cache: npm

      - name: Install
        run: npm ci

      - name: Lint
        run: npm run lint

      - name: Typecheck
        run: npm run typecheck

      - name: Test
        run: npm test -- --ci
EOF
      ;;
    python)
      cat > "$QUALITY_DEST" <<'EOF'
# Quality — lint, typecheck, unit tests (required)
name: Quality

on:
  push:
    branches: [main, master]
  pull_request:

permissions:
  contents: read

jobs:
  quality:
    name: Lint, types, tests
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.12"
          cache: pip

      - name: Install
        run: |
          python -m pip install --upgrade pip
          if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
          if [ -f requirements-dev.txt ]; then pip install -r requirements-dev.txt; fi
          pip install ruff mypy pytest || true

      - name: Lint
        run: ruff check .

      - name: Typecheck
        run: mypy .

      - name: Test
        run: pytest
EOF
      ;;
    *)
      cp "$CANON_ROOT/scaffold/ci/quality.yml" "$QUALITY_DEST"
      ;;
  esac
  echo "  wrote: .github/workflows/quality.yml"
fi

# accessibility.yml
A11Y_DEST="$WF_DEST/accessibility.yml"
if [[ -e "$A11Y_DEST" && "$FORCE" -ne 1 ]]; then
  echo "  skip (exists): .github/workflows/accessibility.yml  (pass --force to regenerate after confirm)"
elif [[ "$WITH_UI" -eq 1 ]]; then
  cat > "$A11Y_DEST" <<'EOF'
# Accessibility — required when the product has user-facing UI
name: Accessibility

on:
  push:
    branches: [main, master]
  pull_request:

permissions:
  contents: read

jobs:
  axe:
    name: axe accessibility
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      # TODO: build or start the app, then run axe against a real URL or static export.
      # Example:
      # - run: npm ci && npm run build && npm run start &
      # - run: npx --yes wait-on http://127.0.0.1:3000
      # - run: npx --yes @axe-core/cli http://127.0.0.1:3000 --exit

      - name: Refuse empty accessibility gate
        run: |
          echo "::error::Wire a real axe/pa11y run (see ACCESSIBILITY.md)."
          exit 1
EOF
  echo "  wrote: .github/workflows/accessibility.yml (active — wire axe before merge)"
else
  copy_file "$CANON_ROOT/scaffold/ci/accessibility.yml" "$A11Y_DEST"
fi

copy_file "$CANON_ROOT/scaffold/PROJECT_CREATION.md" "$TARGET/CANON_CHECKLIST.md"

ensure_git_repo() {
  if [[ ! -d "$TARGET/.git" ]]; then
    git -C "$TARGET" init -b main >/dev/null
    echo "  wrote: git init (main)"
  fi
}

ensure_github_remote() {
  ensure_git_repo

  if ! command -v gh >/dev/null 2>&1; then
    GH_BLOCKER="Install GitHub CLI (gh) and run: gh auth login"
    echo "  warn: gh not found — remote/PR steps left in CANON_NEXT_STEPS.md"
    return 1
  fi
  if ! gh auth status >/dev/null 2>&1; then
    GH_BLOCKER="Run: gh auth login"
    echo "  warn: gh not authenticated — remote/PR steps left in CANON_NEXT_STEPS.md"
    return 1
  fi

  if git -C "$TARGET" remote get-url origin >/dev/null 2>&1; then
    echo "  skip (origin exists): $(git -C "$TARGET" remote get-url origin)"
    return 0
  fi

  local vis_flag="--private"
  [[ "$GITHUB_VISIBILITY" == "public" ]] && vis_flag="--public"

  echo "  creating GitHub repo (${GITHUB_VISIBILITY})…"
  if [[ -n "$GITHUB_REPO" ]]; then
    if ! gh repo create "$GITHUB_REPO" "$vis_flag" --source="$TARGET" --remote=origin; then
      GH_BLOCKER="gh repo create ${GITHUB_REPO} failed — create the remote manually, then: git remote add origin <url>"
      return 1
    fi
  else
    if ! gh repo create "$vis_flag" --source="$TARGET" --remote=origin; then
      GH_BLOCKER="gh repo create failed — pass --github=owner/name or create the remote manually"
      return 1
    fi
  fi
  echo "  wrote: origin → $(git -C "$TARGET" remote get-url origin)"
  return 0
}

open_baseline_pr() {
  ensure_git_repo

  if ! command -v gh >/dev/null 2>&1 || ! gh auth status >/dev/null 2>&1; then
    GH_BLOCKER="${GH_BLOCKER:-Run: gh auth login}"
    echo "  warn: cannot open PR without gh auth"
    return 1
  fi
  if ! git -C "$TARGET" remote get-url origin >/dev/null 2>&1; then
    GH_BLOCKER="No origin remote — use --github or git remote add origin <url>"
    echo "  warn: $GH_BLOCKER"
    return 1
  fi

  # Seed main with an empty commit so the baseline can land as a real PR diff
  git -C "$TARGET" checkout -B main >/dev/null 2>&1 || true
  if ! git -C "$TARGET" rev-parse HEAD >/dev/null 2>&1; then
    git -C "$TARGET" commit --allow-empty -m "chore: init repository"
    echo "  wrote: empty init commit on main"
  fi
  git -C "$TARGET" push -u origin main

  git -C "$TARGET" checkout -B "$CANON_BASELINE_BRANCH"
  git -C "$TARGET" add -A
  if ! git -C "$TARGET" diff --cached --quiet || ! git -C "$TARGET" diff --quiet; then
    git -C "$TARGET" add -A
    git -C "$TARGET" commit -m "Apply Canon baseline"
    echo "  wrote: commit on ${CANON_BASELINE_BRANCH}"
  else
    echo "  skip: nothing new to commit for baseline PR"
  fi

  git -C "$TARGET" push -u origin "$CANON_BASELINE_BRANCH"

  (
    cd "$TARGET"
    existing="$(gh pr list --head "$CANON_BASELINE_BRANCH" --json url -q '.[0].url' 2>/dev/null || true)"
    if [[ -n "$existing" && "$existing" != "null" ]]; then
      echo "  skip (PR exists): $existing"
      exit 0
    fi
    url="$(gh pr create --base main --head "$CANON_BASELINE_BRANCH" --title "Apply Canon baseline" --body "$(cat <<'PRBODY'
## Summary
- Apply Canon agent rules, domain docs, and day-one CI workflows
- Open via PR so merge gates can enforce the baseline

## Test plan
- [ ] Required checks configured on `main`
- [ ] Quality workflow wired to real lint/typecheck/test commands

PRBODY
)")" || true
    if [[ -n "$url" ]]; then
      echo "  wrote: PR $url"
    else
      echo "  warn: gh pr create failed — see CANON_NEXT_STEPS.md for manual commands"
      return 1
    fi
  )
}

if [[ "$DO_GITHUB" -eq 1 ]]; then
  echo
  echo "GitHub remote"
  ensure_github_remote || true
fi

NEXT_STEPS="$TARGET/CANON_NEXT_STEPS.md"
cat > "$NEXT_STEPS" <<EOF
# Canon — finish setup (then delete this file)

**Done ≠ local commits.** Baseline must land via a **PR to \`main\`** on GitHub so CI can gate merges.

EOF

if [[ -n "$GH_BLOCKER" ]]; then
  cat >> "$NEXT_STEPS" <<EOF
## 0. Blocking: GitHub CLI

$GH_BLOCKER

Then re-run from the project folder, or continue the commands below.

EOF
fi

cat >> "$NEXT_STEPS" <<'EOF'
## 1. Ensure git + GitHub remote

```bash
# if needed
git init -b main

# create remote (private default) — pick a name
gh auth status   # must succeed
gh repo create YOUR_ORG_OR_USER/YOUR_REPO --private --source=. --remote=origin
# or: gh repo create YOUR_ORG_OR_USER/YOUR_REPO --public --source=. --remote=origin
```

If `origin` already exists, skip create.

## 2. Commit baseline on a branch (not “finished on main”)

```bash
git checkout -b chore/canon-baseline
git add .
git commit -m "Apply Canon baseline"
git push -u origin chore/canon-baseline
```

## 3. Open a PR to main

```bash
gh pr create --base main --head chore/canon-baseline --title "Apply Canon baseline" --body "$(cat <<'PRBODY'
## Summary
- Apply Canon agent rules, domain docs, and day-one CI workflows
- Land via PR so merge gates enforce the baseline

## Test plan
- [ ] Required checks configured on main
- [ ] Quality workflow wired to real commands

PRBODY
)"
```

Do **not** auto-merge. Agents merge only if you say “merge …”. After green checks, **you** merge.

## 4. Make scripts match CI (if Node/Python)

EOF

if [[ "$STACK" == "node" ]]; then
  cat >> "$NEXT_STEPS" <<'EOF'
In `package.json`, ensure these scripts exist (names must match `.github/workflows/quality.yml`):

```json
"scripts": {
  "lint": "...",
  "typecheck": "...",
  "test": "..."
}
```

EOF
elif [[ "$STACK" == "python" ]]; then
  cat >> "$NEXT_STEPS" <<'EOF'
Confirm `ruff`, `mypy`, and `pytest` work locally, or edit `.github/workflows/quality.yml` to match your toolchain.

EOF
else
  cat >> "$NEXT_STEPS" <<'EOF'
Edit `.github/workflows/quality.yml` and replace the failing placeholder with your real install / lint / typecheck / test commands.

EOF
fi

cat >> "$NEXT_STEPS" <<'EOF'
## 5. Fill product-specific blanks

- `SECURITY.md` — secrets manager, rotation owner
- `ARCHITECTURE.md` — what this product is
- `ACCESSIBILITY.md` / `AI_INTEGRATION.md` — if those apply

## 6. Protect main (before feature work)

In the GitHub repo:

1. Settings → Code security → enable **Dependency graph**
2. Settings → Branches / Rules → require on `main`:
   - Secrets Scan
   - Dependency Review (PRs)
   - SAST
   - Quality
   - Accessibility (only if you have UI)

## 7. Point your coding agent here

Standing instruction: “Follow AGENTS.md and PROJECT_RULES.md.”
Many tools auto-read AGENTS.md; if not, paste that once as a project rule.

## 7b. Delivery route (pick one)

Host “don’t commit unless asked” conflicts with Canon’s default (open PRs for non-trivial work). **Record Route A or Route B** before deleting this file:

- **Route A — Prefer delivery:** agents open PRs without asking each time. Optional: copy `.cursor/rules/canon-delivery.mdc`. Never merge unless you say “merge …”.
- **Route B — Prefer ask-before-commit:** agents ask before commit/PR; you still land baseline on `main` via a human-driven PR/MR for CI.

Do not leave this unresolved.

## 8. Credit Canon in your README (optional)

```markdown
Baseline from [Canon](https://github.com/kyrkewood/canon).
```

Or re-run apply with `--credit`. Skip for private/internal repos if you prefer.

## 9. Delete this file

After the baseline PR is **merged** to `main`, protection is on, and **Route A or B** (section 7b) is recorded, delete `CANON_NEXT_STEPS.md`.
Keep `CANON_CHECKLIST.md` only if you still want the long checklist.

Full detail: Canon’s `scaffold/PROJECT_CREATION.md`.
EOF

echo "  wrote: CANON_NEXT_STEPS.md"

if [[ "$CREDIT" -eq 1 ]]; then
  README_DEST="$TARGET/README.md"
  if [[ -f "$README_DEST" ]] && grep -q 'github.com/kyrkewood/canon' "$README_DEST"; then
    echo "  skip (already credited): README.md"
  elif [[ -f "$README_DEST" ]]; then
    printf '\n%s\n' "$CANON_CREDIT_LINE" >> "$README_DEST"
    echo "  wrote: README.md credit line"
  else
    printf '%s\n' "$CANON_CREDIT_LINE" > "$README_DEST"
    echo "  wrote: README.md (credit only — add your own project docs)"
  fi
fi

if [[ "$OPEN_PR" -eq 1 ]]; then
  echo
  echo "Open baseline PR"
  if ! git -C "$TARGET" remote get-url origin >/dev/null 2>&1; then
    if [[ "$DO_GITHUB" -eq 1 ]]; then
      ensure_github_remote || true
    else
      GH_BLOCKER="No origin remote — re-run with --github[=owner/name], or: git remote add origin <url>"
      echo "  warn: $GH_BLOCKER"
    fi
  fi
  open_baseline_pr || true
fi

if [[ -n "$GH_BLOCKER" ]]; then
  if ! grep -q '## 0. Blocking: GitHub CLI' "$NEXT_STEPS" 2>/dev/null; then
    tmp="$(mktemp)"
    {
      head -n 4 "$NEXT_STEPS"
      cat <<EOF

## 0. Blocking: GitHub CLI

$GH_BLOCKER

Then continue from step 1 below.

EOF
      tail -n +5 "$NEXT_STEPS"
    } > "$tmp"
    mv "$tmp" "$NEXT_STEPS"
  fi
fi

echo
echo "Done."
echo
echo "Next: open $TARGET/CANON_NEXT_STEPS.md — remote + PR to main is required."
echo "Deep checklist (optional): $TARGET/CANON_CHECKLIST.md"
if [[ -n "$GH_BLOCKER" ]]; then
  echo "Blocked on GitHub: $GH_BLOCKER"
fi
