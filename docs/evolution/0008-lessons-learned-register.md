# 0008 — Lessons-Learned Register for Pivoted Features

- **Date:** 2026-07-09
- **Status:** proposed
- **Priority:** 2 of 6 — high value because it prevents a specific, predictable failure: re-testing an already-disproven hypothesis.
- **Status:** adopted (2026-07-08)

## Problem

`pivot.sh` archives a dead feature's `01_discovery_ideation` and `02_definition_metrics` folders to `.archive/failed_hypotheses/FEATURE_NAME/` — nothing is destroyed, but nothing is surfaced either. Three features and a few months later, nobody scanning the backlog will remember that a similar idea was already tried and failed, because the evidence is sitting inside an archived folder nobody has a reason to open.

## Proposed change

Have `pivot.sh` append one line to a running `LESSONS_LEARNED.md` at the product root every time it archives a feature — the assumption that was tested, and why it failed (pulled from the feature's `Riskiest_Assumption.md` and, if it exists, `Validation_Report.md`).

## Stepwise implementation plan (not yet executed)

1. Add a `LESSONS_LEARNED.md` template (empty table: Feature, Assumption Tested, Why It Failed, Date, Archive Path) to `.mwp-templates/`, created at product init the same way `GLOBAL_CONTEXT.md` is.
2. Extend `pivot.sh`: after archiving, read the first few lines of the archived `Riskiest_Assumption.md` (and `Validation_Report.md` if present) and append a row to `LESSONS_LEARNED.md` before finishing.
3. If those files are missing or unparseable, append a row with what's available and a note that the summary is incomplete — don't fail the pivot over it.
4. Test against the sandbox feature used for the original `pivot.sh` verification, confirming a row appears correctly.
5. Reference `LESSONS_LEARNED.md` in stage `01_discovery_ideation/CONTEXT.md` as required reading before forming a new riskiest assumption, so the check is structural, not just "remember to look."

## What happens if adopted

Turns the pivot mechanism from "safely delete and forget" into "safely delete and remember" — closing a real institutional-memory gap at near-zero cost, since the archiving already happens.

## Outcome (2026-07-08)

All 5 steps implemented, with one added robustness measure beyond the plan:

1. `.mwp-templates/LESSONS_LEARNED.template.md` added — same "copy at product init" pattern as `GLOBAL_CONTEXT.template.md`, referenced in `README.md`'s product-init walkthrough as a new step 5.
2. `pivot.sh` extended with an `extract_summary()` helper: first non-empty, non-heading line of a file, pipe-escaped and truncated to stay a valid single-line markdown table cell. Pulls the assumption from the just-archived `Riskiest_Assumption.md` and the outcome from `Validation_Report.md`.
3. Missing-file handling confirmed: a clear placeholder string appears in the row instead of failing the pivot, for either source file independently.
4. Tested in a sandbox: a full pivot (both source files present) produced a correct row with both fields populated; an early pivot (neither source file present) produced a correct row with both placeholders, and the pivot still completed normally in both cases.
5. Stage `01_discovery_ideation`'s `CONTEXT.md` now references `LESSONS_LEARNED.md` as required reading before forming a new riskiest assumption, both in "Input scope" and as an explicit "Execution rules" instruction.

**Beyond the plan:** `pivot.sh`'s existing behavior only ever archived `01_discovery_ideation` and `02_definition_metrics` — everything else, including any `06_validation_gtm/outputs/Validation_Report.md`, was already being permanently deleted by the existing `rm -rf "$FEATURE_DIR"` line, before this entry existed. Since `pivot.sh` is primarily invoked *after* stage 06 per the "On Pivot" step in each stage 06 `CONTEXT.md`, `Validation_Report.md` will often exist at pivot time. The extraction now deliberately happens **before** that `rm -rf` runs, specifically so this file's content gets distilled into the register instead of silently destroyed — this wasn't a bug introduced by this entry, but it was a real gap this entry's own reasoning surfaced and closed as a natural side effect.

**Also surfaced, logged separately rather than fixed here:** working out the correct relative path for stage 01's new `LESSONS_LEARNED.md` reference required counting real directory depth (`features/<name>/<stage>/` is 3 levels below product root), which doesn't match the `../../` (2 levels) already used by every existing stage `CONTEXT.md` for other product-root references (`GLOBAL_CONTEXT.md`, `CRITICAL_ESCALATION.md`, etc.). Used the arithmetically correct `../../../` for this new reference rather than copying the existing pattern, and logged the discrepancy as entry `0025` for review rather than silently mass-editing 6 existing files based on my own count.

Per the versioning workflow from entry `0015`: `.mwp-templates/01_discovery_ideation/CONTEXT.md` bumped from `template-version: 2` to `3`; `.mwp-templates/LESSONS_LEARNED.template.md` is a new file, starting at `template-version: 1`; root `VERSION` bumped from `8` to `9`.
