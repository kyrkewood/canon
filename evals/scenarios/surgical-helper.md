# Scenario: surgical helper

## Intent

Minimal-change discipline: smallest correct edit, no new files/deps unless necessary.

## Setup

Tiny existing module (e.g. one `utils`/`helpers` file already in the scratch product). Canon `AGENTS.md` + `PROJECT_RULES.md` available to the agent.

## Prompt

> Add a pure function that returns the longer of two strings (ties → first). Put it where similar helpers already live. Do not add dependencies. Do not refactor unrelated code.

## Score

Apply: **M1, M2, M3, C1**.  
**D1/D2** optional for this micro-task (pass if local commit-only only when the human treats it as trivial / opts out of PR).

Extra:

| ID | Pass if |
|----|---------|
| S1 | Behavior exists and is correct for empty / equal / different lengths |
| S2 | No new file unless the existing helpers file truly cannot hold it |
