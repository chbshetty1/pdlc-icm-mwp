# 0030 — Dependency-Free Test Harness for `scripts/*.sh`

- **Date:** 2026-07-08
- **Status:** adopted (2026-07-08)
- **Priority:** surfaced via external research (same source as entry `0029` — a user-supplied Google AI Mode transcript on framework testing methodology), not from the ranked backlog.

## Problem

Every one of this framework's own 7 scripts has, so far, only ever been verified by hand: copy into a sandbox scratch directory, run it, read the output, confirm it looks right, note the result in that entry's Outcome section. This has genuinely caught real bugs — entry `0014`'s `$?`-clobbering trap bug was found exactly this way — but it has no persistence. Nothing stops that same bug (or one like it) from being silently reintroduced the next time `trap ... EXIT` logic gets touched, because there's no standing check that runs it again.

`docs/DEVELOPMENT.md`'s own script conventions already half-describe a test discipline ("test in a scratch copy, never against the committed repo directly") without any actual harness enforcing it — every entry re-derives its own ad hoc verification from scratch.

## Proposed change

A `tests/` directory at the framework repo root, dependency-free — no `bats-core` or any other third-party test framework, just bash, since that's already this framework's one hard prerequisite (`scripts/*.sh` themselves need nothing beyond it). Structure:

- `tests/lib/assert.sh` — minimal assertion helpers (`assert_equal`, `assert_file_exists`, `assert_contains`, etc.), sourced by each test file.
- `tests/test_<script>.sh` — one file per script (or grouped where scripts share a workflow, e.g. `test_registry_status.sh` covers both `registry.sh` and `status.sh` together since a realistic test fixture naturally exercises both). Each builds its own scratch copy of `scripts/` + `.mwp-templates/` in a `mktemp -d` directory, runs assertions against real script behavior, and cleans up after itself — same "scratch copy, never the committed repo" rule `docs/DEVELOPMENT.md` already states, just now mechanically enforced rather than manually remembered per entry.
- `tests/run_tests.sh` — runner: executes every `test_*.sh` as its own subprocess (not sourced, so one test's `cd` or early `exit` can't corrupt another), aggregates pass/fail counts, exits non-zero on any failure.

Test priority: previously-documented gotchas first (entry `0014`'s `$?`-trap bug, entry `0027`'s `--sprint` `FEATURE_META.md` skip), then one smoke-level suite per remaining script covering its stated core contract (entry `0004`'s non-blocking token guardrail, entry `0005`'s shared-path collision block, entry `0009`'s audit log, entry `0012`'s `Learnings_Note.md` folding on both `sync.sh` and `pivot.sh`, entry `0008`'s `LESSONS_LEARNED.md` row, entry `0010`'s archive-not-delete for `.escalations_archive/`, entry `0003`'s C-V-R sorting into the right registry section, entry `0016`'s status rollup, `compact.sh`'s snapshot-required contract).

`tests/` is framework-repo-only, like `docs/evolution/` and `docs/DEVELOPMENT.md` — a product repo built from this framework doesn't need to re-test the framework's own scripts, it just uses them. Not added to the "Using this framework for a new product" copy steps.

## Stepwise implementation plan

1. Attempt to install `bats-core` (the transcript's suggested tool) to confirm it's actually viable in the environments this framework gets developed in. If it can't be installed cleanly (no root, no network egress, or any other real friction), fall back to a self-contained bash-only harness instead — don't force a dependency the framework doesn't otherwise need.
2. Write `tests/lib/assert.sh` and `tests/run_tests.sh`.
3. Write one `test_*.sh` per script (or logical group), prioritized as described above.
4. Run the full suite in a sandbox against the real `scripts/` + `.mwp-templates/` content, fix anything a test catches, confirm a clean pass.
5. Copy the passing harness into the actual repo tree (never write directly against the committed repo without having verified in scratch first, per `docs/DEVELOPMENT.md`'s own conventions).
6. Update `docs/DEVELOPMENT.md`: add a "Testing this framework" section (how to run `tests/run_tests.sh`, when a change should get new coverage, why no `bats-core`) and add `tests/` to the documentation map / adoption checklist as a step ("if your change touches a tested behavior, run `tests/run_tests.sh` before writing the Outcome section").
7. Add `tests/` to `README.md`'s file table as framework-repo-only.
8. Update `EVOLUTION_LOG.md`'s table row.

## What happens if adopted

Every documented gotcha in this framework's own history (the `$?`-trap bug, the sprint dead-weight file) gets a standing regression check instead of living only as prose in an evolution entry. Future changes to `scripts/` get a fast, dependency-free way to confirm they haven't broken something already fixed once.

## Outcome (2026-07-08)

Step 1 changed the plan's outcome, not its intent: `bats-core` could not be installed in the sandbox this framework is developed in — no root for `apt`, and the sandbox's network egress blocks `git clone` (proxy 403), `npm install -g bats` (registry 403), and presumably any other package-registry fetch. Rather than block on an unreachable dependency, built the self-contained bash-only harness the plan's step 1 explicitly allowed for as a fallback. In hindsight this is arguably the better fit anyway: `bats-core` would have been a new cross-platform install requirement (another entry in `docs/TOOLING_MATRIX.md`, another Windows Git-Bash-vs-WSL question) for a framework whose only other hard prerequisite is bash itself.

All remaining steps executed as written:

2. `tests/lib/assert.sh` (9 helpers: `assert_equal`, `assert_file_exists`, `assert_file_not_exists`, `assert_dir_exists`, `assert_dir_not_exists`, `assert_contains`, `assert_not_contains`, `assert_file_contains`, `assert_file_not_contains`) and `tests/run_tests.sh` (runs each `test_*.sh` as its own subprocess, parses a `SUMMARY: N run, M failed` line each suite prints, aggregates and exits non-zero on any failure) written.
3. Seven suites written, one per script except `registry.sh`/`status.sh` (grouped, since a realistic fixture naturally exercises both): `test_scaffold.sh` (13 assertions — feature vs. sprint structure, entry 0027's `FEATURE_META.md` skip, refuses to clobber an existing workspace), `test_logging.sh` (7 — the entry 0014 `$?`-trap regression, checked against both `scaffold.sh` and `sync.sh`'s bad-usage paths), `test_sync.sh` (13 — basic advance, entry 0009 audit log, entry 0004 non-blocking token warning, entry 0012 learnings fold with comment-line filtering, entry 0005 shared-path collision block), `test_pivot.sh` (10 — entry 0008 `LESSONS_LEARNED.md` row, entry 0012 stage-06 fold on both `--pivot` and `--persevere`, clean failure on an unknown feature), `test_registry_status.sh` (10 — entry 0003's four-way C-V-R sorting, and a direct check that a sprint's `FEATURE_META.md` is never read by `registry.sh` even when one exists, confirming entry 0027's resolution actually holds), `test_compact.sh` (5 — refuses without `SUMMARY_SNAPSHOT.md`, archives everything else, keeps the snapshot), `test_doctor.sh` (4 — a smoke test that only pins down the reporting contract, since which tools are actually installed is this machine's state, not the script's behavior to assert on).
4. Ran in a sandbox scratch copy first: 62 assertions, 0 failures, across all 7 suites.
5. Copied the verified harness into the real repo tree.
6. `docs/DEVELOPMENT.md` gained a new "Testing this framework" section and the adoption checklist's step 6 area now includes running `tests/run_tests.sh` before writing an Outcome section when the change touches tested behavior.
7. `README.md`'s file table gained a `tests/` row, framework-repo-only.
8. `EVOLUTION_LOG.md` row added.

No `VERSION` bump — `tests/` doesn't ship to product repos (framework-repo-only, same category as `docs/evolution/` and `docs/DEVELOPMENT.md`, neither of which bump `VERSION` per entry `0020`'s precedent), and no file under `scripts/`, `.mwp-templates/`, `CLAUDE.md`, or a "Travels with new products" doc was modified — only read, to write tests against.
