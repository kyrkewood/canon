# Feature: Security CI hardening

## Purpose

Make Canon’s security gates OWASP-scoped, merge-blocking, and actionable — with visible waivers instead of silent bypass.

## How it should work

- `sast.yml` runs Semgrep `p/owasp-top-ten` + `p/security-audit` with `--error` and SARIF upload.
- Secrets + dependency review remain required and failing.
- `dast.yml` is opt-in (manual copy); ZAP baseline against `ZAP_TARGET_URL` once enabled.
- Waivers use tool-native suppressions + logged justification (`SECURITY.md`).

## Non-goals

- Not a hosted DAST service or default ZAP on every apply.
- Not a custom waiver DSL — use Semgrep/Gitleaks/ZAP mechanisms.

## Decisions

| Date | Decision | Why | Revisit when |
|------|----------|-----|--------------|
| 2026-08-06 | Replace `semgrep --config auto` with OWASP packs | Review gap | Pack renames |
| 2026-08-06 | DAST opt-in, not day-one required | Needs running app in CI | Most products have preview URLs |
