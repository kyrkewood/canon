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
  docs/agent/git-delivery.md
  docs/agent/pull-requests.md
  docs/agent/checklist.md
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

# Default is opt-out: a non-AWS adopter gets no infra files.
for f in infra .github/workflows/infra-synth.yml .github/workflows/infra-deploy.yml; do
  if [[ -e "$TMP/$f" ]]; then
    echo "smoke-apply: $f must not be installed without --infra=aws-free" >&2
    exit 1
  fi
done
if grep -q '6b' "$TMP/CANON_NEXT_STEPS.md"; then
  echo "smoke-apply: CANON_NEXT_STEPS.md must not mention infra steps without --infra=aws-free" >&2
  exit 1
fi

TMP_INFRA="$(mktemp -d "${TMPDIR:-/tmp}/canon-smoke-infra.XXXXXX")"
trap 'rm -rf "$TMP" "$TMP_GENERAL" "$TMP_INFRA"' EXIT
echo "smoke-apply: --infra=aws-free target=$TMP_INFRA"
"$ROOT/scaffold/apply.sh" "$TMP_INFRA" --stack=none --infra=aws-free

for f in \
  infra/package.json infra/package-lock.json infra/canon-infra.env infra/eslint.config.mjs \
  infra/bin/app.ts infra/bin/oidc.ts infra/lib/github-oidc-stack.ts infra/test/oidc.test.ts \
  .github/workflows/infra-synth.yml .github/workflows/infra-deploy.yml; do
  if [[ ! -e "$TMP_INFRA/$f" ]]; then
    echo "smoke-apply: --infra=aws-free should install $f" >&2
    exit 1
  fi
done
if ! grep -q '"lint"' "$TMP_INFRA/infra/package.json"; then
  echo "smoke-apply: infra/package.json needs a lint script" >&2
  exit 1
fi
if ! grep -q 'working-directory: infra' "$TMP_INFRA/.github/workflows/quality.yml"; then
  echo "smoke-apply: quality.yml should run the infra job from infra/" >&2
  exit 1
fi
for step in 'bootstrap' 'deploy:oidc' 'AWS_DEPLOY_ROLE_ARN' 'DEPLOY_ENABLED' 'required reviewers' 'Protect `main`'; do
  if ! grep -q "$step" "$TMP_INFRA/CANON_NEXT_STEPS.md"; then
    echo "smoke-apply: CANON_NEXT_STEPS.md should cover: $step" >&2
    exit 1
  fi
done

# Deploy workflow safety properties.
DEPLOY="$TMP_INFRA/.github/workflows/infra-deploy.yml"
if [[ "$(grep -c 'id-token: write' "$DEPLOY")" -ne 1 ]] || [[ "$(awk '/^permissions:/{f=1} /^jobs:/{f=0} f' "$DEPLOY" | grep -c 'id-token')" -ne 0 ]]; then
  echo "smoke-apply: infra-deploy.yml must request id-token at job level only, once" >&2
  exit 1
fi
for needle in "vars.DEPLOY_ENABLED == 'true'" 'group: deploy' 'cancel-in-progress: false' 'environment: prod' 'aws-actions/configure-aws-credentials' 'vars.AWS_DEPLOY_ROLE_ARN' 'workflow_dispatch'; do
  if ! grep -qF "$needle" "$DEPLOY"; then
    echo "smoke-apply: infra-deploy.yml should contain: $needle" >&2
    exit 1
  fi
done
if sed 's/#.*//' "$TMP_INFRA/.github/workflows/infra-synth.yml" | grep -qE 'id-token|aws-actions|AWS_|secrets\.'; then
  echo "smoke-apply: infra-synth.yml must hold no credentials or id-token permission" >&2
  exit 1
fi

# Re-running with --force must not clobber the adopter's config.
sed -i.bak 's/^CANON_INFRA_REGION=.*/CANON_INFRA_REGION=eu-west-1/' "$TMP_INFRA/infra/canon-infra.env"
"$ROOT/scaffold/apply.sh" "$TMP_INFRA" --stack=none --infra=aws-free --force --yes >/dev/null
if ! grep -q '^CANON_INFRA_REGION=eu-west-1$' "$TMP_INFRA/infra/canon-infra.env"; then
  echo "smoke-apply: --force overwrote infra/canon-infra.env" >&2
  exit 1
fi

if "$ROOT/scaffold/apply.sh" "$TMP_INFRA" --infra=gcp >/dev/null 2>&1; then
  echo "smoke-apply: --infra=gcp should be rejected" >&2
  exit 1
fi

echo "smoke-apply: PASS"
