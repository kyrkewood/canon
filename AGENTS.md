# AGENTS.md

Standing instructions for coding agents. This is the master doc: short rules here, detail in the docs it points to. Load a pointer only when the task needs it.

## Always

- **Verify delivery against the spec.** If five things were asked for, confirm five exist. No partial delivery as "done".
- **Distrust green checks.** Read the implementation, not just test output. Watch for stubs, hardcoded returns, and tests that only exercise a mock.
- **Minimal change.** Smallest diff that solves the ask. No new dependencies or files without approval, no public API changes unless requested, no unrelated refactors. Honour any allowed/forbidden paths the human names.
- **Thin slice first.** Land one end-to-end path before broadening. If scope is ambiguous, ask once for bounds before a large edit.
- **Clean up in the same task.** Remove dead code, unused imports, debug prints, and temp files. Tighten before calling it done.
- **Be specific about quality.** Error handling, edge cases, naming, and conventions are part of the ask, not extras.
- **Hand back the wheel.** After a few failed attempts at the same approach, stop and ask. Roll back a tangled branch rather than stacking patches. Never force-push shared branches or rewrite shared history.
- **Conflicting rules.** Follow the stricter one and call out the conflict.
- **Commit each step** on a feature branch. Non-trivial work ends in an open PR (in cloud sessions this file is the explicit request for it). **Merge only when told "merge …"** – ship, fix, land, and green CI are not permission.

## Load when

| Task | Read |
|------|------|
| Always | [`PROJECT_RULES.md`](PROJECT_RULES.md) – principles, code and test norms |
| Writing prose (UI copy, docs, commits, PR text) | [`HOUSE_STYLE.md`](HOUSE_STYLE.md) |
| Branching, committing, opening or merging PRs (Route A/B) | [`docs/agent/git-delivery.md`](docs/agent/git-delivery.md) |
| Writing a PR body, screenshots, walkthroughs | [`docs/agent/pull-requests.md`](docs/agent/pull-requests.md) |
| Finishing a task (self-check) | [`docs/agent/checklist.md`](docs/agent/checklist.md) |
| Auth, data, crypto, deps, secrets, privacy | [`SECURITY.md`](SECURITY.md) |
| UI | [`ACCESSIBILITY.md`](ACCESSIBILITY.md) |
| APIs, MCP, agent surfaces | [`AI_INTEGRATION.md`](AI_INTEGRATION.md) |
| Changing system shape | [`ARCHITECTURE.md`](ARCHITECTURE.md) |
| Adding or changing a capability | [`docs/features/`](docs/features/) – create or update `<capability>.md` from [`_TEMPLATE.md`](docs/features/_TEMPLATE.md) in the same PR |
| Scaffolding a new product | [`ADOPT.md`](ADOPT.md), [`scaffold/PROJECT_CREATION.md`](scaffold/PROJECT_CREATION.md); ask for the apply choices first, then run `scaffold/apply.sh` |
