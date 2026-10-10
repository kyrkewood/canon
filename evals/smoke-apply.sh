#!/usr/bin/env bash
# Apply Canon into a temp dir and assert the expected baseline file set.
# Usage: ./evals/smoke-apply.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d "${TMPDIR:-/tmp}/canon-smoke.XXXXXX")"
TMP_GENERAL="$(mktemp -d "${TMPDIR:-/tmp}/canon-smoke-general.XXXXXX")"
cleanup() { rm -rf "$TMP" "$TMP_GENERAL"; }
trap cleanup EXIT

echo "smoke-apply: target=$TMP"
"$ROOT/scaffold/apply.sh" "$TMP" --stack=none

required=(
  AGENTS.md
  CLAUDE.md
  .cursor/rules/agents.mdc
  PROJECT_RULES.md
  SECURITY.md
  ACCESSIBILITY.md
  AI_INTEGRATION.md
  ARCHITECTURE.md
  HOUSE_STYLE.md
  CANON_NEXT_STEPS.md
  docs/features/README.md
  docs/features/_TEMPLATE.md
  docs/session-handoff.md
  docs/house-style/README.md
  docs/house-style/uk.md
  docs/house-style/general.md
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

if ! grep -q 'Route A' "$TMP/CANON_NEXT_STEPS.md" || ! grep -q 'Route B' "$TMP/CANON_NEXT_STEPS.md"; then
  echo "smoke-apply: CANON_NEXT_STEPS.md should flag delivery Route A/B" >&2
  exit 1
fi

if ! grep -q 'HOUSE_STYLE' "$TMP/CANON_NEXT_STEPS.md"; then
  echo "smoke-apply: CANON_NEXT_STEPS.md should mention HOUSE_STYLE.md" >&2
  exit 1
fi

if ! grep -q 'en-GB' "$TMP/HOUSE_STYLE.md"; then
  echo "smoke-apply: default HOUSE_STYLE.md should be the uk starter" >&2
  exit 1
fi

if grep -q 'This repo is \*\*Canon\*\*' "$TMP/HOUSE_STYLE.md"; then
  echo "smoke-apply: applied HOUSE_STYLE.md leaked Canon product notes" >&2
  exit 1
fi

echo "smoke-apply: general profile target=$TMP_GENERAL"
"$ROOT/scaffold/apply.sh" "$TMP_GENERAL" --stack=none --house-style=general

if ! grep -q 'en-US' "$TMP_GENERAL/HOUSE_STYLE.md"; then
  echo "smoke-apply: --house-style=general should copy the general starter" >&2
  exit 1
fi

if grep -q 'This repo is \*\*Canon\*\*' "$TMP_GENERAL/HOUSE_STYLE.md"; then
  echo "smoke-apply: general HOUSE_STYLE.md leaked Canon product notes" >&2
  exit 1
fi

echo "smoke-apply: PASS"
