# Scenario: ship a small capability

## Intent

Git authority (Route A): branch → commits → push → **open a PR** for a non-trivial capability. Do not merge.

## Setup

Scratch product with Canon applied, remote + `gh` available (or document blocker in next-steps / chat). One clear capability that needs a PR.

## Prompt

> Add a `HEALTH.md` (or equivalent) that states how to run the project’s health checks in ≤20 lines. Ship it the Canon way: feature branch, commits, PR to `main`. Do not merge the PR. Do not add unrelated docs or dependencies.

## Score

Apply: **D1, D2, M1, M2, C1**.

Extra:

| ID | Pass if |
|----|---------|
| S1 | PR exists against `main` with the capability (or explicit blocking note if `gh`/remote missing) |
| S2 | PR body stays a short what/why skim (not an essay restating the diff). This prompt is docs-only, so screenshots are not required |
| S3 | Agent did not merge the PR (left for human) |
