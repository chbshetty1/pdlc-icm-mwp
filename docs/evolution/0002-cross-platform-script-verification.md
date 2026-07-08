# 0002 — Verify Cross-Platform Script Execution

- **Date:** 2026-07-08
- **Status:** adopted (2026-07-09)
- **Priority:** 1 of 5 — highest, because it's a potential live blocker rather than a design improvement.

## Outcome

Verified from Git Bash on the actual Windows machine this framework is used on: `scaffold.sh` created the feature tree with correct `CONTEXT.md` substitution, `sync.sh` correctly moved `outputs/` into the next stage's `inputs/`, and `pivot.sh` correctly archived to `.archive/failed_hypotheses/` and removed the feature folder. No portability fixes needed — best-case outcome from the plan's step 4. `README.md` updated with the one-line prerequisite.

## Problem

`scaffold.sh`, `sync.sh`, `pivot.sh`, and `compact.sh` are bash scripts. They were written and tested inside a Linux sandbox. The actual usage environment (confirmed this session) is Windows PowerShell. PowerShell cannot execute `.sh` files directly — it needs Git Bash, WSL, or an equivalent bash environment. Nobody has confirmed these scripts run correctly from the real, native environment where they'll actually be used. Everything we call "tested" so far was tested somewhere the user isn't standing.

## Proposed change

Before relying on these scripts day-to-day, confirm they run correctly from the actual working environment, and either document the required setup or add a thin cross-platform entry point.

## Stepwise implementation plan (not yet executed)

1. From a Git Bash or WSL prompt (not plain PowerShell) at the repo root, run `bash scripts/scaffold.sh --feature FEAT-TEST_env_check`.
2. Confirm the folder tree, `CONTEXT.md` substitutions, and exit messages match what was seen in the sandbox test.
3. Run `sync.sh`, `pivot.sh` against that test feature the same way, then delete the test feature folder (it should never be committed — `features/` is gitignored).
4. If it works cleanly: add a one-line prerequisite note to `README.md` ("Requires Git Bash or WSL on Windows") and close this entry as adopted with no code changes needed.
5. If it doesn't work cleanly: capture the exact error, and decide between (a) fixing the bash script for portability, or (b) writing thin `.ps1`/`.cmd` wrapper scripts that shell out to bash, or (c) a Python rewrite of the four scripts (most portable, but adds a dependency).

## What happens if adopted

Either a one-line documentation fix (best case) or a decision to add wrapper scripts / rewrite in a more portable language (worse case, but better to know now than after the first real feature runs into it mid-pipeline).
