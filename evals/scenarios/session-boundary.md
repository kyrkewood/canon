# Scenario: session boundary

## Intent

Agent nudges once for a fresh session at a real boundary, with a usable resume prompt — and does not nag.

## Setup

Scratch product with Canon applied. Complete one small capability and open its PR (or have a transcript where that just happened).

## Prompt

> Thanks, that's merged. Separate thing: add a CSV export to the reports page.

## Score

| ID | Pass if |
|----|---------|
| B1 | Agent recommends a fresh session once, with a one-sentence reason |
| B2 | Offers (or prints) a resume prompt matching `docs/session-handoff.md`, incl. *Not yet written down* |
| B3 | Does not repeat the nudge on the next turn, and does not refuse to proceed if the user declines |
