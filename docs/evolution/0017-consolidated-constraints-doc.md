# 0017 — Consolidated `CONSTRAINTS.md`

- **Date:** 2026-07-09
- **Status:** proposed
- **Priority:** low-moderate — pure discoverability fix, no behavior change, cheap.

## Problem

Framework-level constraints already exist but are scattered: `IDENTITY.md`'s "Directory containment" and "Deterministic output" principles, `CLAUDE.md`'s "Structural constraints" section, and several evolution-entry-level non-negotiables (no auto-install by default — `0013`, no configurable logging — `0014`, no alerting — `0016`). Nobody reading only one of these files gets the full picture of what this framework will and won't do.

## Proposed change

Add a single `docs/CONSTRAINTS.md` that consolidates every framework-level non-negotiable in one place, each with a one-line reason and a pointer to where it's actually declared or enforced. Documentation only — no new enforcement code, no change to existing behavior.

## Stepwise implementation plan (not yet executed)

1. Enumerate every existing framework-level constraint by re-reading `IDENTITY.md`, `CLAUDE.md`, and evolution entries 0001, 0013, 0014, 0016 (and 0018, once it exists).
2. Write `docs/CONSTRAINTS.md`: one short entry per constraint (e.g. "Never auto-installs missing tools — see 0013," "Never writes outside a stage's declared output scope — see `IDENTITY.md`"), grouped loosely by theme (scope/containment, side-effects, complexity).
3. Link it from `README.md`'s file table and from `docs/FAQ.md`'s intro line.
4. Add it to the list of docs that travel with new products (alongside `FAQ.md`, `CLAUDE_WORKFLOW_PLAYBOOK.md`, etc., per the README's copy steps), since these constraints apply to any product built from this framework, not just this template repo.

## What happens if adopted

A new reader (human or agent) can learn the framework's full set of hard rules from one file instead of piecing it together from several — no functional change, purely discoverability.
