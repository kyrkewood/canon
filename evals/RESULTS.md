# Results log

One line per run. Newest at the bottom.

Format: `YYYY-MM-DD | smoke|scenario-id | pass|fail | note`

Only log **observed** runs (scratch product or CI smoke). Do not log meta “we merged Canon PRs” as scenario passes.

```
2026-08-01 | smoke | pass | scripts/verify.sh → evals/smoke-apply.sh --stack=none
2026-08-01 | surgical-helper | pass | scratch apply+helpers.js; longerOf in existing file; M1–M3,C1,S1,S2; node checks empty/tie/diff
2026-08-01 | no-unasked-deps | pass | scratch main.js JSON logs via console; no package.json/deps; M1–M3,C1,S1
2026-08-01 | ship-capability | fail | no disposable remote in harness — branch/PR not opened; D1 unmet (see evals/README)
```
