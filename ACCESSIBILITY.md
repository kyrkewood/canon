# Accessibility

Domain rulebook for inclusive UI.  
Parent index: [`PROJECT_RULES.md`](PROJECT_RULES.md).  
CI gate: [`scaffold/ci/accessibility.yml`](scaffold/ci/accessibility.yml) (merge-blocking once UI exists).

---

## 1. Targets

- Design default: **WCAG 2.2 AAA** for critical user flows.
- CI floor: **WCAG 2.2 AA** (automated axe / equivalent serious violations fail the build).
- Accessibility failures are bugs — not polish.

---

## 2. Non-Negotiables

- Full keyboard navigation everywhere interactive.
- Screen readers receive:
  - Correct landmarks
  - Meaningful labels
  - Predictable focus order
- Color is never the only means of conveying meaning.
- Color contrast is validated automatically where tools allow; critical AAA contrast is verified manually for primary flows.

---

## 3. Enforcement

- Install and wire `accessibility.yml` when UI ships; do not leave the scaffold as a no-op.
- No UI PR merged without:
  - Passing automated a11y checks for changed surfaces
  - Manual keyboard walkthrough of changed flows
- Prefer an accessibility specialist review (human or agent **driving axe/playwright**) on large UI changes — complementary to CI.

Bonus: agents navigating the UI also work better when these rules hold.

---

## 4. Product-Specific Notes

_Fill in at project creation:_

- UI surfaces in scope:
- Primary user flows (AAA target):
- Assistive-tech test matrix (browsers / SR):
- Last manual a11y review date:
