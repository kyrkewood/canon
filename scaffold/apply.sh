#!/usr/bin/env bash
# Apply the canon baseline into a new or existing project.
# Usage: ./scaffold/apply.sh /path/to/project [--force] [--stack=node|python|none] [--with-ui]
set -euo pipefail

usage() {
  cat <<'EOF'
Apply canon (agent rules + engineering docs + CI) to a project.

Usage:
  ./scaffold/apply.sh <target-dir> [options]

Options:
  --force              Overwrite existing canon files if present
  --stack=node|python|none
                       Prefill quality.yml for that stack (default: auto-detect)
  --with-ui            Include accessibility CI as active (default: copy, keep dormant)
  -h, --help           Show this help

Examples:
  ./scaffold/apply.sh ~/projects/my-app
  ./scaffold/apply.sh . --stack=node --with-ui
  ./scaffold/apply.sh ../new-thing --force

What it does:
  1. Creates the target folder if needed
  2. Copies AGENTS.md, PROJECT_RULES.md, and domain docs
  3. Copies GitHub Actions workflows into .github/workflows/
  4. Writes CANON_NEXT_STEPS.md with the few things only you can finish
EOF
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CANON_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

TARGET=""
FORCE=0
STACK="auto"
WITH_UI=0

for arg in "$@"; do
  case "$arg" in
    -h|--help) usage; exit 0 ;;
    --force) FORCE=1 ;;
    --with-ui) WITH_UI=1 ;;
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

mkdir -p "$TARGET"
TARGET="$(cd "$TARGET" && pwd)"

copy_file() {
  local src="$1"
  local dest="$2"
  if [[ -e "$dest" && "$FORCE" -ne 1 ]]; then
    echo "  skip (exists): ${dest#"$TARGET"/}  (use --force to overwrite)"
    return 0
  fi
  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
  echo "  wrote: ${dest#"$TARGET"/}"
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
  echo "  skip (exists): .github/workflows/quality.yml  (use --force to overwrite)"
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
  echo "  skip (exists): .github/workflows/accessibility.yml  (use --force to overwrite)"
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

NEXT_STEPS="$TARGET/CANON_NEXT_STEPS.md"
cat > "$NEXT_STEPS" <<EOF
# Canon — finish setup (then delete this file)

Canon docs and CI are in this repo. Do these next (order matters):

## 1. Make scripts match CI (if Node/Python)

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
## 2. Fill the blank product sections

Open and complete the “Product-Specific Notes” (or equivalent) in:

- `SECURITY.md` — secrets manager, rotation owner
- `ARCHITECTURE.md` — what this product is
- `ACCESSIBILITY.md` / `AI_INTEGRATION.md` — if those apply

## 3. Push to GitHub and turn on protection

```bash
git add .
git commit -m "Apply canon baseline"
git push
```

In the GitHub repo:

1. Settings → Code security → enable **Dependency graph** (for dependency review)
2. Settings → Branches / Rules → require these checks on `main`:
   - Secrets Scan
   - Dependency Review (PRs)
   - SAST
   - Quality
   - Accessibility (only if you have UI)

## 4. Point your coding agent here

Open this project in Cursor, Claude Code, Codex, Lovable, or similar.
Standing instruction: “Follow AGENTS.md and PROJECT_RULES.md.”
Many tools auto-read AGENTS.md; if not, paste that line once as a project rule.
Plain-language setup help: see Canon’s ADOPT.md.

## 5. Delete this file

When the checklist above is done, delete `CANON_NEXT_STEPS.md`.  
Keep `CANON_CHECKLIST.md` only if you still want the long-form checklist; otherwise delete it too.

Full detail: see the original canon repo’s `scaffold/PROJECT_CREATION.md`.
EOF

echo "  wrote: CANON_NEXT_STEPS.md"
echo
echo "Done."
echo
echo "Next: open $TARGET/CANON_NEXT_STEPS.md and finish the short list."
echo "Deep checklist (optional): $TARGET/CANON_CHECKLIST.md"
