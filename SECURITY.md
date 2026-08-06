# Security

Domain rulebook for secrets, encryption, OWASP-oriented practice, and privacy-aware logging.  
Parent index: [`PROJECT_RULES.md`](PROJECT_RULES.md).  
CI gates: [`scaffold/ci/`](scaffold/ci/) (`secrets-scan`, `dependency-review`, `sast`).

---

## 1. Secrets & Credentials

- **Never put keys in version control.**
- **Always use a secrets manager** (or platform secret store via OIDC) — not long-lived secrets in CI config files.
- Local `.env` files hold non-production placeholders only; real values stay out of git.
- Document in this file (per product): secrets manager choice, rotation owner, break-glass CI bypass accounts, and any time-bounded gate exceptions.

---

## 2. Encryption & Key Management (BYOK-Ready)

### Rules
- All sensitive data **must be encryptable at rest**.
- Encryption logic must be **decoupled from any specific cloud KMS**.
- Keys must be **rotatable without data migration**.
- Encryption boundaries must align with **customer isolation**.

### Required Design Patterns
- Introduce a `KeyProvider` abstraction even if only env-based keys are used initially.
- Use envelope encryption:
  - Per-customer DEK
  - Master key (future BYOK)
- Persist metadata: `customer_id`, `key_id`, `encryption_version`

### Smell Test
> If this table leaked, could we honestly say “the data is encrypted with customer-controlled keys”?

If not, redesign.

### Tests (not only design)
- Rules above are incomplete without tests: wrong-tenant decrypt fails, rotation still reads old envelopes, plaintext never lands in the persistence path you claim is encrypted.
- Canon does **not** ship a crypto implementation — products do. The baseline requires the abstraction **and** behavior coverage.

---

## 3. OWASP-Oriented Application Security

Apply these on every feature that handles input, auth, or data. Prefer CI (Semgrep / dependency review) plus targeted review over prompt-only audits.

### Always check
| Area | Expectation |
|------|-------------|
| Injection | Parameterized queries / safe APIs; no string-built SQL, shell, or LDAP |
| Authn | Verified session/token handling; secure cookie flags; no homemade crypto |
| Authz | Explicit permission checks on every sensitive operation — deny by default |
| SSRF | Do not fetch attacker-controlled URLs without allowlists / network egress controls |
| CSRF | Protect cookie-based state-changing requests |
| XSS | Encode/escape by context; prefer frameworks that auto-escape |
| Sensitive data exposure | No secrets in logs, URLs, or client bundles |
| Broken access control | Object-level authz (IDOR) tested for core resources |
| Supply chain | Lockfiles committed; high/critical vulnerable deps fail CI |
| Security misconfiguration | No debug modes or default creds in production |

### App-level security tests
- SAST and dependency review are necessary but not sufficient.
- Keep a dedicated security behavior suite (folder or script, e.g. `*.security.test.*` / `test:security`) covering at least: access control / IDOR, injection boundaries you own, auth session mistakes, and integrity of sensitive writes.
- Naming and runner are product choice; the convention is **security behavior is tested in-repo** and runs in CI (or the local verify umbrella).

### Review trigger
Run a security / OWASP specialist review (human or agent **with tools**) when a PR touches authentication, authorization, cryptography, multi-tenant data, file/URL fetching, or public APIs. Review complements `sast.yml`; it does not replace it.

### CI gates (merge-blocking)
| Gate | Workflow | Notes |
|------|----------|-------|
| Secrets | `secrets-scan.yml` | Gitleaks |
| Dependencies | `dependency-review.yml` | High+ severity fails PRs |
| SAST | `sast.yml` | Semgrep **OWASP Top 10** + security-audit; SARIF when available |
| DAST | `dast.yml` (opt-in) | ZAP baseline against a running URL — enable only when you have a CI-reachable instance |

Gates must **fail the job** on findings (not report-only). Prefer logs/SARIF that cite **rule ID + file/line**.

### Waivers (visible, not silent)
Do **not** delete or `continue-on-error` a required security workflow to green the build. Use tool-native suppressions with an on-diff justification:

| Tool | Mechanism | Required |
|------|-----------|----------|
| Semgrep | `# nosemgrep` on the line, or `.semgrepignore` with comment | Rule ID + reason + owner + expiry in the PR / `SECURITY.md` CI exceptions |
| Gitleaks | `.gitleaksignore` | Same |
| Dependency review | `allow` / license config in the action, or documented exception | Same |
| DAST / ZAP | Alert allowlist in the action config | Same |

Opaque green under deadline pressure is gate-gaming — actionable failures + visible waivers are the intended escape hatch (see `AGENTS.md` — distrust green checkmarks).

---

## 4. Logging, Telemetry & GDPR

### Rules
- Logs are **diagnostic**, not archival.
- **No raw PII** in logs—ever.
- Logs must be structured, redactable, and correlatable.

### Mandatory Log Fields
- `event_name`
- `timestamp`
- `request_id`
- `customer_id` (hashed or pseudonymous)
- `data_classification` (`public | internal | sensitive`)

### PII Handling
- Hash identifiers (email, user ID) with a salt.
- Truncate or summarize free-text inputs.
- Maintain an explicit allowlist of loggable fields.

### GDPR Defaults
- Logs have TTLs.
- Logs are region-aware.
- Deletion hooks exist for user data, derived data, and cached AI outputs.

> If it can’t be deleted, it shouldn’t be logged.

### Privacy review trigger
When touching logging, analytics, retention, or export/delete flows, run a privacy pass against this section.

### Logger tests
- Structured logging rules need tests that raw PII / secrets do not appear in emitted fields (allowlist + redaction). Design-only loggers are incomplete.

---

## 5. Product-Specific Notes

_Fill in at project creation:_

- Secrets manager:
- Key rotation owner:
- Data regions:
- CI exceptions (id, reason, expiry):
- Threat model link / last review date:
