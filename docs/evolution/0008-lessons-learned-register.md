# 0008 — Lessons-Learned Register for Pivoted Features

- **Date:** 2026-07-09
- **Status:** proposed
- **Priority:** 2 of 6 — high value because it prevents a specific, predictable failure: re-testing an already-disproven hypothesis.

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
