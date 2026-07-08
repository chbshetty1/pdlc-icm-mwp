# 0017 — Consolidated `CONSTRAINTS.md`

- **Date:** 2026-07-09
- **Status:** adopted (2026-07-08)
- **Priority:** low-moderate — pure discoverability fix, no behavior change, cheap. Ranked 14 of 20 by entry `0026`'s unified backlog re-prioritization.

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

## Outcome (2026-07-08)

All 4 steps executed, plus the follow-through entry `0018` itself called for:

1. Enumerated constraints by re-reading `.mwp-templates/IDENTITY.md`, `CLAUDE.md`'s "Structural constraints"/"Failure handling"/"Automated skill routing" sections, and evolution entries `0001`, `0005`, `0010`, `0013`, `0014`, `0016`, `0018`.
2. `docs/CONSTRAINTS.md` written: 10 constraints across three groups — Scope & containment (directory containment, self-reported Context Manifest checking, single-owner shared state), Side-effects & escalation (no silent auto-install, escalate-don't-loop, archive-not-delete), and Complexity & coordination (no configurable logging, no alerting, generated files never hand-edited, advisory-only token guardrails). Each entry states the rule, why, and where it's enforced.
3. Linked from `README.md`'s file table (new row, marked "Travels with new products") and from `docs/FAQ.md`'s intro line.
4. Added to the "Using this framework for a new product" copy steps in `README.md`, alongside `FAQ.md`/`CLAUDE_WORKFLOW_PLAYBOOK.md`/etc.

**Beyond the plan:** `.mwp-templates/CRITICAL_ESCALATION.md`'s Context Manifest disclosure (added by entry `0018`) explicitly stated it was living there only as an "interim home... once `docs/CONSTRAINTS.md` exists, it belongs there instead." Moved the full disclosure into `docs/CONSTRAINTS.md`'s "Scope & containment" section and replaced it in `CRITICAL_ESCALATION.md` with a one-line pointer. `template-version` bumped 3→4 on that file. Also updated the FAQ's own pre-existing "Is there a single place..." entry, which previously said "not yet."

Root `VERSION` bumped 11→12 (`.mwp-templates/CRITICAL_ESCALATION.md` and `docs/CONSTRAINTS.md`, a travels-with-products doc, both shipped).
