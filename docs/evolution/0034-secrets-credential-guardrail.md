# 0034 — Secrets/Credential Guardrail

- **Date:** 2026-07-08
- **Status:** adopted (2026-07-08)
- **Priority:** surfaced during a stage-01/02 discovery pass (guardrails question) and user-approved for implementation.

## Problem

Nothing in this framework checks for accidentally-hardcoded secrets or credentials before a stage's outputs sync forward. A discovery-stage transcript could paste an API key from a source system; a stage 03 spec could reference a real test credential instead of a placeholder; a stage 05 code dump could include a `.env`-style file or an actual private key. `sync.sh` already has two guardrails at the transition point (entry 0004's token-ceiling warning, entry 0005's shared-path collision block) but neither looks at content for anything credential-shaped, and once something syncs forward — and especially once it's committed to the product's real repo — a leaked secret can't be un-leaked the way an over-length file can just be trimmed.

## Proposed change

Add a `check_secrets_guardrail()` function to `sync.sh`, run on every sync (not just specific stage transitions, since a secret can show up in any stage's raw notes or output). Mechanical, regex-based — the same class of guardrail as entry 0005's shared-path check, explicitly not a real secret scanner (no entropy analysis, no provider-specific validation API). Catches: a private-key block (`-----BEGIN ... PRIVATE KEY-----`), an AWS-shaped access key ID (`AKIA[0-9A-Z]{16}`), a credential-shaped filename (`.pem`, `.key`, `id_rsa`, etc.) regardless of content, and a generic `api_key`/`secret`/`password`/`token`/`access_key` assignment with a non-trivial (16+ character) value — while explicitly excluding `{{PLACEHOLDER}}`-style template values to avoid false-positiving on the framework's own template convention. Unlike entry 0004's guardrail (warns, never blocks), this blocks the sync outright and auto-writes `BLOCKED_REASON.md`, the same severity as entry 0005's collision check — a leaked credential is a different order of consequence than an oversized file.

## Stepwise implementation plan

1. Add `check_secrets_guardrail()` to `sync.sh`, called early (right after the existing "already blocked" check, before the token-guardrail and shared-path checks).
2. Write `tests/test_secrets_guardrail.sh` covering: a clean sync (no false positive), each of the 4 detection patterns individually, and a `{{PLACEHOLDER}}` value correctly NOT blocking.
3. Test in a sandbox scratch copy first, then verify `tests/test_sync.sh`'s existing fixtures don't accidentally trip the new check (none of them contain credential-shaped content).
4. Add a `docs/CONSTRAINTS.md` entry under "Side-effects & escalation," alongside entry 0005's shared-path rule.
5. Run the full `tests/run_tests.sh` suite to confirm no regression.

## What happens if adopted

A stage output containing something that looks like a hardcoded credential gets caught and blocked at the sync gate, with the specific file and pattern named in the auto-written `BLOCKED_REASON.md`, before it can propagate into later stages or get committed. Not airtight — a well-obfuscated or unusually-shaped secret can still slip through — but it catches the common, careless case for free.

## Outcome (2026-07-08)

Implemented as written, no deviations. `check_secrets_guardrail()` added to `sync.sh` immediately after the existing `BLOCKED_REASON.md` presence check, ahead of the token-guardrail and shared-path checks. `docs/CONSTRAINTS.md`'s "Side-effects & escalation" section gained a new bullet describing the rule, its severity relative to entry 0004's warn-only guardrail, and its explicit non-airtightness — consistent with how entry 0005's collision check is described in "Scope & containment."

`tests/test_secrets_guardrail.sh` added: 11 assertions covering a clean pass, all 4 detection patterns (private-key block, AWS-shaped key, generic credential assignment, credential-shaped filename), and the `{{PLACEHOLDER}}` false-positive-avoidance case — all passed on the first real run. Cross-checked `tests/test_sync.sh`'s existing fixtures (discovery notes, an oversized file, a shared-path collision file) against the new patterns — none collide, no regression.

Verified from a sandbox-local path with zero Windows-mount involvement (see entry 0036's Outcome). Full suite re-run after: **186 assertions across 11 suites, 0 failures** (175 prior + 11 new).

`scripts/sync.sh` ships to every new product — `VERSION` bumped MINOR per entry `0029`'s tiers (backward-compatible addition: a sync that previously succeeded with clean content still succeeds identically; only content that looks like a hardcoded credential newly blocks).
