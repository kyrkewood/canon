# Git delivery

Loaded from [`AGENTS.md`](../../AGENTS.md) when branching, committing, or opening PRs.

## Routes

**Default (Route A):** non-trivial work → branch → commits → push → **open a PR**. Human merges after checks.  
**Route B:** ask before commit/PR – only if recorded at apply (`CANON_NEXT_STEPS` §7b).  
If unset: flag A/B once, wait. Do not silently override host "ask first" rules or silently skip PRs.

| Do | Don't |
|----|--------|
| One capability → one branch → one PR | Pile onto an open mega-PR / uncommitted heap |
| Open the PR under Route A (or ask under Route B) | Treat local-only as "done" under Route A |
| **Merge only if told "merge …"** (eg merge #12) | Merge on fix / ship / land / clear the pile / green CI |
| Stop if `gh`/remote blocked; note it | Force-push `main` or rewrite shared history |

"Ship" means the PR is up for review – **not** merged. GitHub + Actions + `gh` are the default forge/CI; other hosts: same loop with MR + blocking checks.

## Commits

Commit incrementally on a feature branch, not one giant commit at the end. Commits are not a substitute for a PR. Features and their tests go in separate commits (see [`PROJECT_RULES.md`](../../PROJECT_RULES.md)).

## Fix forward or roll back

If the last slice is clearly wrong, prefer reverting that commit or branch tip and retrying cleanly over stacking compensatory patches. Fix forward when the mistake is small and local. Don't delete others' branches or work without an explicit ask.
