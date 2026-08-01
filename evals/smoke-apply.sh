#!/usr/bin/env bash
# Apply Canon into a temp dir and assert the expected baseline file set.
# Usage: ./evals/smoke-apply.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d "${TMPDIR:-/tmp}/canon-smoke.XXXXXX")"
cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT

echo "smoke-apply: target=$TMP"
"$ROOT/scaffold/apply.sh" "$TMP" --stack=none

required=(
  AGENTS.md
  PROJECT_RULES.md
  SECURITY.md
  ACCESSIBILITY.md
  AI_INTEGRATION.md
  ARCHITECTURE.md
  CANON_NEXT_STEPS.md
  docs/features/README.md
  docs/features/_TEMPLATE.md
  .github/workflows/secrets-scan.yml
  .github/workflows/dependency-review.yml
  .github/workflows/sast.yml
  .github/workflows/quality.yml
)

missing=0
for f in "${required[@]}"; do
  if [[ ! -e "$TMP/$f" ]]; then
    echo "missing: $f" >&2
    missing=1
  fi
done

if [[ "$missing" -ne 0 ]]; then
  echo "smoke-apply: FAIL" >&2
  exit 1
fi

if ! grep -q 'PR' "$TMP/CANON_NEXT_STEPS.md"; then
  echo "smoke-apply: CANON_NEXT_STEPS.md should mention PR delivery" >&2
  exit 1
fi

echo "smoke-apply: PASS"
