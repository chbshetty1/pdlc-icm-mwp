# 0009 — Sync Audit Trail

- **Date:** 2026-07-09
- **Status:** proposed
- **Priority:** 3 of 6 — real traceability gap, moderate urgency.

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
