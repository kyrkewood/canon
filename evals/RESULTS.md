# Results log

One line per run. Newest at the bottom.

Format: `YYYY-MM-DD | smoke|scenario-id | pass|fail | note`

```
2026-08-01 | smoke | pass | evals/smoke-apply.sh via scripts/verify.sh; --stack=none file set ok
2026-08-01 | ship-capability | pass | meta: open PRs #13–#16 merged via branch+PR (not local-only); pile cleared
2026-08-01 | surgical-helper | pass | meta: conflict resolutions kept both sides; no new deps; feature doc added for stuck rails
2026-08-01 | no-unasked-deps | pass | meta: dogfood used bash/stdlib only for verify+smoke; no new packages
```
