# 0033 — Template/Contract Validation Tests

- **Date:** 2026-07-08
- **Status:** adopted (2026-07-08)
- **Priority:** surfaced during a stage-01/02 discovery pass (testing-scope question) and user-approved for implementation.

## Problem

Entry 0030's test suite covers `scripts/*.sh` behavior thoroughly, but nothing checks the other half of the contract: that `.mwp-templates/` content actually matches the exact string/regex patterns the scripts mechanically parse out of it. Three concrete drift risks exist today, none currently caught by anything:

1. `sync.sh`'s `check_token_guardrail()` greps each stage's `CONTEXT.md` for `Max [0-9]+ tokens`. If a future edit rewords that line (e.g. "Token budget: 1500" instead of "Max 1500 tokens"), the function's `[ -z "$ceiling" ] && return 0` means the guardrail silently stops firing — no warning, no error, just quietly disabled.
2. `sync.sh`'s shared-path collision check greps `GLOBAL_CONTEXT.md` for lines starting `^- shared_path:`. Same failure mode: reformat that line and the check silently finds zero shared paths, defeating entry 0005's whole purpose.
3. `registry.sh`'s `get_field()` greps `FEATURE_META.md` for `^${field}:` per field (`feature_id`, `c`, `v`, `r`, `status`, `is_core_anchor`). A template edit that renames or reformats a field breaks scoring silently — the feature just falls into "not yet scored" or scores as if the field were blank.

All three are the same underlying gap: scripts and templates are two files that must agree on an exact string shape, and nothing enforces that agreement except a human remembering to check both sides on every template edit.

## Proposed change

Add `tests/test_template_contracts.sh`: a suite that checks templates against the exact patterns the scripts parse, not against what the templates *say* in prose. Covers: `{{FEATURE_NAME}}` placeholder presence (all 6 stage `CONTEXT.md`), the `Max [0-9]+ tokens` pattern (all 6), the 6 numbered section headers (structural consistency, not machine-parsed but worth catching drift on), a `template-version` marker on every travelling template file (entry 0015's own contract), the `^- shared_path:` example line in `GLOBAL_CONTEXT.template.md`, and all 7 fields `registry.sh` parses from `FEATURE_META.template.md`.

## Stepwise implementation plan

1. Write `tests/test_template_contracts.sh` using the existing `tests/lib/assert.sh` helpers — no new test infrastructure needed.
2. Run it against the real repo's current templates — should pass 0 failures, confirming the templates as they exist today already satisfy every contract this suite checks (this is a regression guard, not a fix for an existing bug).
3. Add it to the suites `tests/run_tests.sh` already auto-discovers (no wiring needed — it globs `test_*.sh`).
4. Run the full suite to confirm no interaction with existing suites.

## What happens if adopted

A future edit to any `.mwp-templates/*.md` file that breaks one of the three silent-failure patterns above gets caught by `tests/run_tests.sh` at edit time, with a message naming exactly which pattern broke — instead of being discovered later as a mysteriously-disabled guardrail or a feature that silently never scores.

## Outcome (2026-07-08)

Implemented mostly as written, with one real finding along the way rather than a clean first-run pass. The first version of the suite (a uniform "every stage has a `Max N tokens` line" check, 70 assertions) found one genuine failure: `05_development_test/CONTEXT.md` has no numeric token ceiling at all — its "Token guardrails" section only says to bundle via `repomix` once `./src/` exceeds ~15 files. This turned out to be intentional, not drift: stage 05's deliverables are code/tests, not prose bounded by the word-count heuristic the other 5 stages use, and `CLAUDE.md`'s own automation routing already documents `repomix` as stage 05's guardrail mechanism. Forcing a fake "Max N tokens" line into that template to make the test pass would have been dishonest about what actually bounds that stage's output.

Fixed by making the exemption explicit instead of papering over it: the suite now excludes `05_development_test` from the numeric-ceiling check and separately asserts (a) it has no numeric ceiling, by design, and (b) it does mention `repomix` as its alternate guardrail — so a future edit that silently drops stage 05's `repomix` guidance without adding a numeric ceiling would still be caught.

Verified from a sandbox-local path with zero Windows-mount involvement (see entry 0036's Outcome for why that matters), after confirming via line-count comparison against `Read`-tool output that the mount-copied `.mwp-templates/` used for the test run was itself uncorrupted this time. Final run: 71 assertions, 0 failures, against the real repo's current templates.

Full suite re-run after: **154 assertions across 9 suites, 0 failures** (83 prior + 71 new).

`tests/` is framework-repo-only (per entry 0030) — no `VERSION` bump.
