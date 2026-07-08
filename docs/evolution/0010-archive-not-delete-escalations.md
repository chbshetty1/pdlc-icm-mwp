# 0010 — Archive, Don't Delete, Resolved Escalations

- **Date:** 2026-07-09
- **Status:** adopted (2026-07-08)
- **Priority:** 4 of 6 — small fix, real institutional-memory value. Ranked 13 of 20 by entry `0026`'s unified backlog re-prioritization.

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

## Outcome (2026-07-08)

All 4 steps addressed:

1. `.mwp-templates/CRITICAL_ESCALATION.md`'s "Human resolution" section rewritten: "deletes or archives" → "moves the resolved `BLOCKED_REASON.md` to `<feature_root>/.escalations_archive/` — never deletes it." `template-version` bumped 2→3.
2. `scaffold.sh` now creates `$TARGET_DIR/.escalations_archive/` (empty) alongside the 6 stage folders at every feature/sprint scaffold. Tested in a sandbox: `--feature` scaffold produced the folder correctly, empty, at the feature root.
3. Confirmed rather than assumed: `.gitignore` already excludes `.escalations_archive/` wholesale, since it lives under `features/<name>/` and the repo's `.gitignore` already ignores `features/` and `sprints/` entirely — no separate rule needed. `repomix` never sees it either, since every invocation in this framework is explicitly scoped to a subdirectory (stage 05's `CONTEXT.md` runs it on `./src/` only, not the feature root), and `graphify` is likewise scoped to a single stage folder (`04_architecture_design`, run as `graphify .` from inside that folder) — neither tool bundles the feature root where the archive lives.
4. No `escalations_archive.sh` helper built. Same reasoning as entries `0013`/`0014`: this is a plain accumulating folder with no pruning logic and no concrete need for automation yet — building a helper now would be machinery ahead of any actual pain point.

Root `VERSION` bumped 10→11 (only `CRITICAL_ESCALATION.md`'s template-version and `scaffold.sh` shipped changes; no other files touched).
