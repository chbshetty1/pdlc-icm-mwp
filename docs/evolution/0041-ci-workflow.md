# 0041 — CI Workflow for `tests/run_tests.sh`

- **Date:** 2026-07-08
- **Status:** adopted (2026-07-08)
- **Priority:** surfaced during a second stage-01/02 discovery pass (survey of what's still thin, user-requested).

## Problem

`tests/run_tests.sh` (entry 0030) is solid — 203 assertions across 12 suites as of this entry — but nothing runs it automatically. It's a manual step in `docs/DEVELOPMENT.md`'s adoption checklist, meaning a script regression is only caught if a human happens to remember to run the suite before pushing. Nothing in this repo currently enforces that.

## Proposed change

Add `.github/workflows/test.yml`: a single GitHub Actions job, triggered on every push and pull request to `main`, that checks out the repo and runs `bash tests/run_tests.sh`. `run_tests.sh` already exits non-zero when any suite fails (`[ "$TOTAL_FAILED" -eq 0 ] && [ "$SUITES_FAILED" -eq 0 ]`), so no extra plumbing is needed to make a failing suite fail the job.

## Stepwise implementation plan

1. Write `.github/workflows/test.yml`: single job, `ubuntu-latest`, `actions/checkout@v4`, then `bash tests/run_tests.sh`. No matrix, no caching — the whole suite runs in a few seconds (per entry 0037's finding), nothing here is worth optimizing yet.
2. Validate the YAML syntax (`python3 -c "import yaml; yaml.safe_load(...)"`) since this sandbox has no way to trigger an actual GitHub Actions run to observe directly.
3. Update `README.md`'s file table with a row for the new workflow file, marked framework-repo-only (same as `tests/` itself — the workflow is meaningless without the test suite it runs, and `tests/` doesn't travel to product repos).

## What happens if adopted

Every future push or PR to `main` gets `tests/run_tests.sh` run automatically; a regression shows up as a failed check on the commit/PR instead of silently landing until someone happens to run the suite by hand.

## Outcome (2026-07-08)

Implemented as written. One thing worth recording honestly: this entry's verification is necessarily incomplete from this environment. The sandbox this framework is developed in has no way to actually trigger a GitHub Actions run and observe it execute — verification here is limited to (a) YAML syntax validity, confirmed via `python3`'s `yaml.safe_load`, and (b) the underlying command (`bash tests/run_tests.sh`) already being exhaustively tested in every other entry in this session. One syntax note for anyone reviewing the raw YAML: `python3 -c "import yaml; ..."` parses the bare `on:` key as the boolean `True` rather than the string `"on"` — this is a well-known PyYAML/YAML-1.1 quirk (implicit boolean resolution of bare `on`/`off`/`yes`/`no`), not a defect in this file. GitHub's own Actions parser handles `on:` correctly as the trigger key, exactly as written in essentially every published GitHub Actions workflow. Real confirmation that the workflow actually triggers and passes on GitHub itself is a manual follow-up step for whoever pushes this — flagged here rather than glossed over, consistent with how this framework's other environment-verification gaps (e.g. `preflight.ps1`'s can't-run-in-this-sandbox limitation, documented in `docs/FAQ.md`) are stated plainly rather than assumed away.

`README.md`'s file table updated with the new row. No `VERSION` bump: `.github/workflows/` isn't `.mwp-templates/`, `scripts/`, or `CLAUDE.md`, and doesn't travel to product repos (same framework-repo-only reasoning as `tests/` itself, per entry 0030's precedent).
