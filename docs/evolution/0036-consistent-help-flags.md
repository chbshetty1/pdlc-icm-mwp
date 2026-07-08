# 0036 — Consistent `-h`/`--help` Support Across All 7 Scripts

- **Date:** 2026-07-08
- **Status:** adopted (2026-07-08)
- **Priority:** surfaced during a stage-01/02 discovery pass (script-ergonomics/DX question).

## Problem

None of the 7 scripts respond to an explicit help request. `usage()` (or an inline usage message) only fires when required arguments are missing or malformed — running `scaffold.sh -h` today falls through to "missing arguments" handling (since `-h` isn't `--feature`/`--sprint`) rather than printing help and exiting cleanly. `doctor.sh`, `registry.sh`, and `status.sh` have no usage message at all, since they either take no required arguments or only an optional flag.

## Proposed change

Add an explicit `-h`/`--help` check as the first thing each script does after its `trap`/logging setup, printing a one-line usage string plus a one-line description, and exiting `0` (a deliberate request, not an error) — leaving every existing bad-usage path (`exit 1`) completely unchanged.

## Stepwise implementation plan

1. Add the check to `scaffold.sh`, `sync.sh`, `pivot.sh`, `compact.sh` (all of which already have a usage message for the missing-args case — reuse that same text) and to `doctor.sh`, `registry.sh`, `status.sh` (which don't have one yet — write a short new one for each).
2. Test in a sandbox scratch copy: confirm `-h`/`--help` on all 7 scripts prints something and exits 0, and confirm every existing bad-usage case still exits 1 with its original message (i.e. this is purely additive).
3. Add `tests/test_help.sh`: one assertion per script confirming `-h` exits 0 and prints "Usage:", run against the sandbox copy first, then the real repo.
4. Run the full `tests/run_tests.sh` suite to confirm no regression elsewhere.

## What happens if adopted

`<script> --help` works the way it does for almost every CLI tool, instead of accidentally triggering the missing-args error path. No change to any existing invocation.

## Outcome (2026-07-08)

All 4 steps implemented as written, no deviations. `doctor.sh`'s `-h` check was placed before its existing `--install-missing` check (both read `${1:-}`, so ordering has to be explicit — `-h` wins if both were somehow passed, which isn't a realistic case but was verified deliberately rather than assumed).

`tests/test_help.sh` added: 21 assertions (3 per script — `-h` exit 0, `-h` prints "Usage:", `--help` exit 0 — across all 7 scripts). Full suite re-run after: **83 assertions across 8 suites, 0 failures** (62 prior + 21 new).

**Verification detour worth recording.** The first attempt to run `tests/run_tests.sh` directly against the real repo (through the Windows-mount path this sandbox uses to reach the repo) reported 22 failures across 6 suites — reproducibly, on repeated runs, and even after making a fresh local `cp` of the whole repo first. `bash -n` on the failing copy of `scaffold.sh` found the actual cause: the file had been silently truncated mid-string during the mount read (87 lines instead of 94, cut off inside a quoted string), which is the same class of non-deterministic mount-read corruption already documented in this repo's own FAQ, just showing up as truncation this time instead of null-byte padding. The fix was to stop trusting any mount-read copy for verification: every script and lib file was rebuilt from `Read`-tool-verified content (the `Read` tool, unlike `cp`/`cat` through the mount, has been reliable throughout this session) into a sandbox-local path with zero mount involvement, and the full suite was re-run from there — 83/83 passing, confirming the 22 failures were purely an artifact of reading through the mount, not a real defect in the `-h`/`--help` changes. The lesson (already partially captured in the FAQ) is now sharper: for a *final* verification pass, rebuild from `Read`-tool output rather than trusting `cp`/direct execution against a mount-backed path, even a freshly-copied one.

`scripts/` ships to every new product — `VERSION` bumped MINOR per entry `0029`'s tiers (backward-compatible addition, nothing already scaffolded breaks by staying on an older version).
