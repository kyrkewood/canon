# Accessibility

Domain rulebook for inclusive UI.  
Parent index: [`PROJECT_RULES.md`](PROJECT_RULES.md).  
CI gate: [`scaffold/ci/accessibility.yml`](scaffold/ci/accessibility.yml) (merge-blocking once UI exists).

---

## 1. Targets

- **Required (design + CI): WCAG 2.2 AA** for user-facing UI.
- **Optional aspiration:** WCAG 2.2 AAA for critical flows where criteria are human-reviewable (e.g. enhanced contrast). Many AAA criteria are **not** automatable (sign language, reading level, etc.) — do not treat them as a CI gate.
- Accessibility failures are bugs — not polish.

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
- Contrast: meet **AA** in CI where tools allow; verify critical screens manually.

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
