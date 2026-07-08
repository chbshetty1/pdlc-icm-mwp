# 0040 — Sample Pre-Commit Secrets Hook

- **Date:** 2026-07-08
- **Status:** adopted (2026-07-08)
- **Priority:** surfaced during a second stage-01/02 discovery pass (survey of what's still thin, user-requested), directly motivated by a real incident earlier the same session.

## Problem

Entry 0034's secrets guardrail only protects one surface: a product workspace's `sync.sh` transitions. Nothing catches a credential-shaped string before it's committed to git — in a product repo, or in this framework repo itself. This isn't hypothetical: earlier in this same session, a test fixture in `tests/test_secrets_guardrail.sh` used a Stripe-shaped fake key (`sk_live_...`) that GitHub's server-side push protection correctly flagged — but only *after* the commit already existed locally, requiring a `git commit --amend` to fix rather than catching it before the commit was made at all.

## Proposed change

Add `hooks/pre-commit`, a sample git hook mirroring the existing `hooks/post-commit` convention exactly: optional, copy-to-`.git/hooks/` if wanted, never auto-installed. It reuses the same detection patterns as `sync.sh`'s `check_secrets_guardrail()` (private-key block, AWS-shaped access key ID, credential-shaped filename, generic hardcoded assignment, `{{PLACEHOLDER}}` exclusion) applied to staged files instead of a stage's `outputs/`, blocking the commit with `exit 1` and a clear message (including how to bypass with `--no-verify` for a deliberate false positive).

## Stepwise implementation plan

1. Write `hooks/pre-commit`, adapting `check_secrets_guardrail()`'s patterns to operate on `git diff --cached --name-only --diff-filter=ACM` instead of a fixed directory.
2. Write `tests/test_precommit_hook.sh`: a real scratch git repo (`git init`, the hook copied into `.git/hooks/`), covering a clean commit, each blocking pattern, the `{{PLACEHOLDER}}` non-block case, and confirming `--no-verify` bypasses it as documented.
3. Run the full `tests/run_tests.sh` suite to confirm no interaction with existing suites.
4. Update `README.md`'s file table to mention the new hook alongside the existing `post-commit` one.

## What happens if adopted

Anyone who copies `hooks/pre-commit` into their own `.git/hooks/` (in this framework repo, or a product repo built from it) gets the exact near-miss from earlier in this session caught locally, before a commit exists at all — no amend needed, no dependency on GitHub's own scanning catching it after the fact. Purely opt-in: nothing changes for anyone who doesn't copy it.

## Outcome (2026-07-08)

Implemented as written. `tests/test_precommit_hook.sh` (6 assertions: clean commit, private-key block, generic credential, `{{PLACEHOLDER}}` non-block, `--no-verify` bypass) passed on the first real run in a genuine scratch git repo — this is the first test in this framework's suite that actually exercises git itself rather than just the bash scripts. `README.md`'s file table updated to list both hooks together.

Verified from a sandbox-local path with zero Windows-mount involvement (see entry 0036's Outcome). Full suite: **203 assertions across 12 suites, 0 failures** (197 prior + 6 new).

`hooks/` isn't in the "Travels with new products" copy steps as an automatic step (same as `post-commit` already wasn't) — both are sample files a team opts into, not part of the scripted copy. No `VERSION` bump: nothing in `.mwp-templates/`, `scripts/`, or `CLAUDE.md` changed, and an un-copied sample file has zero effect on any already-scaffolded product.
