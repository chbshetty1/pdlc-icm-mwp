# 0014 — Minimal Operational Log for Script Invocations

- **Date:** 2026-07-09
- **Status:** adopted (2026-07-08)
- **Priority:** moderate — pure observability, not a correctness gap like 0002/0013. Cheap to add, useful for debugging, not urgent. Ranked 20 of 20 by entry `0026`'s unified backlog re-prioritization — the last entry in that ordering.

## Problem

`scaffold.sh`, `sync.sh`, `pivot.sh`, `compact.sh`, and the proposed `doctor.sh` (entry 0013) all echo their actions to stdout, but nothing persists that output. If a script fails in a non-obvious way, or someone wants to know what ran and when after the fact, the only record is whatever's still in terminal scrollback — which is gone the moment the terminal closes.

## Proposed change

Add a single, always-on operational log — no configurable levels, no per-stage overrides. Each script appends one timestamped line per invocation (command, key args, exit code) to `.mwp/framework.log`, in addition to its normal stdout.

Explicitly rejected as part of this proposal: configurable log levels (DEBUG/INFO/WARN/ERROR) and stage-level logging overrides. Two reasons, both tied to existing framework principles rather than just preference:

1. **Token discipline** — a configurable logging subsystem is more surface area `.repomixignore`/Graphify have to be told to exclude, and any misconfiguration risks polluting context exactly when an agent scans a folder.
2. **Rejects the framework's own stated dogma** — entry 0001's first-principles analysis specifically flags "coordination requires software" as the assumption this framework rejects in favor of plain files and explicit gates. A configurable log-level system (a config file, per-stage overrides, level semantics) is that same category of machinery. It would also become a new piece of shared mutable state if the config were editable by multiple features — the same class of problem entry 0003 is trying to fix for the priority registry, reintroduced here.

## Stepwise implementation plan (not yet executed)

1. Add a small shared shell function (e.g. sourced from a `scripts/_log.sh`) that appends `TIMESTAMP | SCRIPT | ARGS | EXIT_CODE` to `.mwp/framework.log`, callable from each script without duplicating logic five times.
2. Wire it into `scaffold.sh`, `sync.sh`, `pivot.sh`, `compact.sh`, and `doctor.sh` (once 0013 builds it) — one call at the end of each script, after the exit code is known.
3. Add `.mwp/framework.log` to `.gitignore` (it's a local operational record, not a design artifact worth committing) and to any Repomix/Graphify ignore config, so it never re-enters model context.
4. Test by running the existing sandbox test sequence (scaffold → sync → pivot) and confirming each invocation produces exactly one correct log line.

## What happens if adopted

A cheap, persistent record of what actually ran and when, without adding any configuration surface, shared state, or token overhead — closes a real debugging gap without reintroducing the "coordination requires software" pattern the framework was built to avoid.

## Outcome (2026-07-08)

All 4 steps executed, with coverage extended beyond the entry's original 5-script list and one real bug caught mid-implementation:

1. `scripts/lib/log.sh` added — a single `log_invocation` function, sourced (not executed), appending `TIMESTAMP | SCRIPT | ARGS | exit=CODE` to `<product-root>/.mwp/framework.log`. Swallows its own mkdir/write failures rather than ever propagating a logging problem into the calling script's exit code.
2. Wired into **7 scripts**, not the entry's original 5 — `registry.sh` and `status.sh` didn't exist when this entry was written (they landed via entries 0003 and 0016 respectively, after 0014 was logged), but they're exactly the kind of script this entry's own reasoning covers, so `docs/DEVELOPMENT.md`'s collision note (which had already flagged this) was followed rather than the entry's literal old list. Wired via `trap 'EC=$?; log_invocation ... "$EC"' EXIT` immediately after each script's `SCRIPT_DIR`/`ROOT_DIR` are computed, rather than manual calls before every exit point — `sync.sh` and `pivot.sh` in particular have several scattered `exit 1`s on failure paths, and a trap fires exactly once no matter which one is taken. `compact.sh` and `doctor.sh` had no `SCRIPT_DIR`/`ROOT_DIR` concept at all before this (neither needed product-root awareness for its own logic) — both gained it, purely so the log line has somewhere to go. `pivot.sh` needed its argument-validation block reordered to *after* `ROOT_DIR` is computed (it previously checked args first), so that even a bad-usage call gets logged, not just successful runs.
3. `.mwp/framework.log` added to `.gitignore`. No separate Repomix/Graphify ignore file exists in this repo (confirmed by search — same finding as during entry 0010's adoption), so `.gitignore` is the only ignore mechanism that needed updating.
4. Tested in a sandbox (fresh script copies written directly into scratch space — every recently-touched script came back truncated via the live mount during this session's testing, including one, `registry.sh`, that entry `0006`'s testing had already shown goes stale even without being edited): ran scaffold (success) → scaffold (bad usage, no args) → sync (success) → sync (genuine failure, nonexistent stage) → pivot (success), and confirmed one correct log line per invocation with the right exit code in each case.

**Bug caught during that same testing, not anticipated by the plan:** the first version of the trap — `trap 'log_invocation ... "$(basename "$0")" ... "$?"' EXIT` — logged every invocation as `exit=0`, including the deliberately-failed bad-usage call. Cause: word expansions in a command's argument list happen left to right, and `$(basename "$0")`'s own command substitution runs (and exits 0) *before* `"$?"` is expanded later in the same argument list — silently overwriting the real exit code. Fixed by capturing `$?` into a variable as its own statement first: `trap 'EC=$?; log_invocation ... "$EC"' EXIT`. Re-tested against three distinct trap-firing scenarios (clean success, early usage-error exit, genuine mid-script failure) — all three now log the correct code. Documented as a named gotcha in `docs/DEVELOPMENT.md`'s script conventions so it doesn't need rediscovering.

Root `VERSION` bumped 16→17 — all 7 scripts, the new `scripts/lib/log.sh`, and `.gitignore` all ship to new products. No `.mwp-templates/` file touched, so no `template-version` bump.
