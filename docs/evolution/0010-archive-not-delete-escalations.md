# 0010 — Archive, Don't Delete, Resolved Escalations

- **Date:** 2026-07-09
- **Status:** proposed
- **Priority:** 4 of 6 — small fix, real institutional-memory value.

## Problem

`.mwp-templates/CRITICAL_ESCALATION.md` currently instructs: "A human... deletes or archives the `BLOCKED_REASON.md`." Deleting is the path of least resistance under time pressure, and once it's gone, the record of what went wrong and how it was resolved is gone with it — losing exactly the kind of failure-mode knowledge that would help the next feature avoid the same mistake.

## Proposed change

Change the instruction from "delete or archive" to "always archive, never delete" — move resolved escalations to a `.escalations_archive/` folder at the feature root instead of removing them.

## Stepwise implementation plan (not yet executed)

1. Edit `.mwp-templates/CRITICAL_ESCALATION.md`'s "Human resolution" section: replace "deletes or archives" with "moves the resolved `BLOCKED_REASON.md` to `.escalations_archive/` (never deletes it)."
2. Add `.escalations_archive/` creation to `scaffold.sh`'s per-feature setup, or have the instruction create it on first use.
3. Confirm `.gitignore`/`repomix` ignore rules exclude `.escalations_archive/` from active context so it doesn't quietly bloat token usage — it's an audit trail, not something that should re-enter the model's working set.
4. No code change to any script is strictly required (this is a human/agent behavioral instruction), but consider adding an `escalations_archive.sh` helper if this proves worth automating rather than trusting manual compliance.

## What happens if adopted

Turns a currently-optional-in-practice "delete or archive" into "archive, full stop" — a one-line policy fix that preserves failure-mode history at essentially zero implementation cost.
