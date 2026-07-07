# 0014 — Minimal Operational Log for Script Invocations

- **Date:** 2026-07-09
- **Status:** proposed
- **Priority:** moderate — pure observability, not a correctness gap like 0002/0013. Cheap to add, useful for debugging, not urgent.

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
