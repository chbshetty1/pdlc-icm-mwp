# 0009 — Sync Audit Trail

- **Date:** 2026-07-09
- **Status:** proposed
- **Priority:** 3 of 6 — real traceability gap, moderate urgency.
- **Status:** adopted (2026-07-07)

## Problem

`sync.sh` moves approved stage outputs forward and refuses to run if `BLOCKED_REASON.md` is present, but it records nothing about the sync itself. If someone later asks "who approved this spec, and when," the only answer is reconstructing it from chat history or memory — exactly the kind of question this framework's whole design philosophy says shouldn't require re-opening a conversation.

## Proposed change

Have `sync.sh` append one line to a `SYNC_LOG.md` at the feature root every time it runs successfully: timestamp, from-stage, to-stage, and (optionally) an approver name if provided as an argument.

## Stepwise implementation plan (not yet executed)

1. Add an optional third argument to `sync.sh`: `<workspace_path> <from_stage> <to_stage> [approver]`.
2. After a successful sync, append a line to `<workspace_path>/SYNC_LOG.md`: `YYYY-MM-DD HH:MM — <from_stage> -> <to_stage> (approved by: <approver|unspecified>)`. Create the file if it doesn't exist.
3. Keep the approver field optional and freeform (a name, an initials, or blank) — don't turn this into an auth system, just a lightweight paper trail.
4. Test against the existing sandbox sync test, confirming the log file is created and appended correctly across multiple syncs.

## What happens if adopted

A feature's full approval history becomes a two-second `cat SYNC_LOG.md` instead of an archaeology project — cheap to add since `sync.sh` already runs at every stage transition.

## Outcome (2026-07-07)

All 4 steps implemented exactly as written:

1. `sync.sh` takes an optional 4th argument, `[approver]`, defaulting to the literal string `unspecified` when omitted.
2. On every successful sync, one line is appended to `<workspace_path>/SYNC_LOG.md`: `YYYY-MM-DD HH:MM — <from> -> <to> (approved by: <approver>)`. The file is created with a one-line header the first time a feature syncs.
3. The approver field is completely freeform — a name, initials, or nothing. No validation, no auth.
4. Tested in a sandbox: two sequential syncs on the same feature (one with an approver, one without) produced a correctly accumulating `SYNC_LOG.md` with both lines, in order, with the right default for the omitted case.

`docs/CLAUDE_WORKFLOW_PLAYBOOK.md`'s stage 01–02 walkthrough and `README.md`'s `scripts/` row updated to mention the optional argument and `SYNC_LOG.md`. No `.gitignore` change needed — `SYNC_LOG.md` lives inside `features/`, which is already gitignored wholesale in the framework repo.

Per the versioning workflow from entry `0015`: only `scripts/sync.sh` changed (no `.mwp-templates/` file touched), so no `template-version` bump applies — root `VERSION` bumped from `4` to `5` since the change ships to products.
