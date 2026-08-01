#!/usr/bin/env bash
# Local verify umbrella for the Canon repo (mirrors cheap merge gates).
# Usage: ./scripts/verify.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

fail=0

echo "== bash -n scaffold/apply.sh =="
bash -n scaffold/apply.sh

echo "== bash -n evals/smoke-apply.sh =="
bash -n evals/smoke-apply.sh

echo "== required canon files =="
required=(
  AGENTS.md
  PROJECT_RULES.md
  SECURITY.md
  ACCESSIBILITY.md
  AI_INTEGRATION.md
  ARCHITECTURE.md
  ADOPT.md
  README.md
  docs/features/README.md
  docs/features/_TEMPLATE.md
  scaffold/apply.sh
  scaffold/PROJECT_CREATION.md
)
for f in "${required[@]}"; do
  if [[ ! -e "$f" ]]; then
    echo "missing: $f" >&2
    fail=1
  fi
done

echo "== no conflict markers in tracked markdown =="
if git ls-files '*.md' | xargs grep -nE '^<<<<<<< |^>>>>>>> ' 2>/dev/null; then
  echo "conflict markers found" >&2
  fail=1
else
  echo "ok"
fi

echo "== evals/smoke-apply.sh =="
./evals/smoke-apply.sh

if [[ "$fail" -ne 0 ]]; then
  echo "verify: FAIL" >&2
  exit 1
fi

echo "verify: PASS"
