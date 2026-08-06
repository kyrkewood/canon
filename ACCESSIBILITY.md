# Accessibility

Domain rulebook for inclusive UI.  
Parent index: [`PROJECT_RULES.md`](PROJECT_RULES.md).  
CI gate: [`scaffold/ci/accessibility.yml`](scaffold/ci/accessibility.yml) (merge-blocking once UI exists).

---

## 1. Targets

| Layer | Level | Meaning |
|-------|-------|---------|
| **Aim** | WCAG 2.2 **AAA** where feasible | Default for design and agent guidance — prefer the highest practical bar |
| **Ship floor (CI)** | WCAG 2.2 **AA** | Merge-blocking automated axe/pa11y; must not regress |
| **Decide** | Human | Whether to accept, defer, or reject AAA recommendations beyond AA |

Many AAA criteria are **not** automatable (sign language, reading level, etc.) — they are never a silent CI gate. Accessibility failures at AA are bugs — not polish.

### Agents: flag high, don’t block on AAA alone

When building or reviewing UI, agents should:

1. Meet **AA** (required) — fix or don’t ship the change.
2. Prefer **AAA** where it’s cheap and clear (e.g. stronger contrast, better text spacing, no timing gimmicks).
3. **Surface** remaining AAA gaps to the human as short recommendations (“could hit AAA by …”) — do not treat them as merge blockers unless the human (or product notes) said this flow requires AAA.
4. Never imply that green AA CI means full WCAG / AAA compliance.

### Green CI ≠ full compliance

Automated axe/pa11y covers a **subset** of AA. A green accessibility job means “no serious automated AA violations on the scanned surfaces,” not “the product is fully WCAG-conformant.” Manual keyboard / screen-reader review remains required for changed flows.

---

## 2. Non-Negotiables

- Full keyboard navigation everywhere interactive.
- Screen readers receive:
  - Correct landmarks
  - Meaningful labels
  - Predictable focus order
- Color is never the only means of conveying meaning.
- Contrast: meet **AA** in CI; prefer **AAA** contrast where practical and flag shortfalls for the human.

---

## 3. Enforcement

- Install and wire `accessibility.yml` when UI ships (`apply.sh --with-ui`); do not leave the refuse-empty stub.
- Point the job at a real URL or static export (see workflow comments / `A11Y_BASE_URL`).
- No UI PR merged without:
  - Passing automated AA checks for changed surfaces (rule IDs visible in the log)
  - Manual keyboard walkthrough of changed flows
- Prefer an accessibility specialist review (human or agent **driving axe/playwright**) on large UI changes — complementary to CI.

### Two complementary layers
1. **URL / CI axe** (`accessibility.yml`) — page-level AA regressions.
2. **In-suite component tests** — interactive components get a11y assertions in the unit/UI run (e.g. `*.a11y.test.*`). Prefer roles/names/keyboard paths over screenshot theater.

Neither replaces the other. Naming and harness are product choice.

Bonus: agents navigating the UI also work better when these rules hold.

---

## 4. Product-Specific Notes

_Fill in at project creation:_

- UI surfaces in scope:
- Primary user flows (manual AA / optional AAA review):
- Assistive-tech test matrix (browsers / SR):
- `A11Y_BASE_URL` or static path used in CI:
- Last manual a11y review date:
