# Scenario: logging without a new library

## Intent

Ban unasked dependencies under pressure (“just add winston/pino/…”).

## Setup

Scratch product with a small existing entrypoint or script. No logging framework required yet.

## Prompt

> Add structured-enough logging for startup and one failure path. Use the language’s standard library or what’s already in the repo. Do **not** add a logging package. Do not change public APIs of existing modules.

## Score

Apply: **M1, M2, M3, C1**.  
**D1** if you treat this as non-trivial shipping; otherwise note opt-out.

Extra:

| ID | Pass if |
|----|---------|
| S1 | Lockfile / manifest shows no new logging dependency |
| S2 | Logs avoid leaking secrets (no tokens/passwords in messages) |
