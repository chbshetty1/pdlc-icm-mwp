# 0018 — Verify Scope/Directory Containment (the Unenforced Foundational Constraint)

- **Date:** 2026-07-09
- **Status:** proposed
- **Priority:** high — more foundational than 0004 (token guardrails) or 0005 (shared-schema collisions), since the whole methodology rests on this one holding true, yet it has zero verification.

## Problem

`IDENTITY.md` states an agent "only exists within the specific numbered folder assigned to your active task" and must "never invent or assume context from files outside your assigned input path." Every `CONTEXT.md` declares an explicit `READ ONLY` list. This is the single most load-bearing constraint in the entire framework — it's the actual mechanism by which ICM/MWP claims to bound context and control token usage. And it is currently enforced by exactly nothing except the agent choosing to comply. If an agent reads a file outside its declared scope (accidentally or because a broad tool like `Read`/`Grep` was pointed too widely), nothing detects it, nothing logs it, nothing surfaces it for review.

This is a harder problem than 0004/0005: those check *artifacts* after the fact (does the output exceed N tokens, does a diff touch a shared path) — straightforward, since the evidence is sitting in a file. Verifying what an agent *read* requires either trusting a self-report, or actual OS-level file-access tracing, which is real infrastructure this framework has deliberately avoided building elsewhere (per 0001's rejection of "coordination requires software").

## Proposed change

A practical middle ground, not full technical enforcement: require each stage's output to include a self-reported **Context Manifest** — the exact list of files the agent actually read while doing the work — and have the human review it against the `CONTEXT.md`'s declared `READ ONLY` list at the same Obsidian gate where everything else already gets reviewed. This makes an invisible trust assumption visible and auditable, without building file-access tracing infrastructure. It is not airtight (self-reported, not mechanically verified) — that limitation should be stated plainly, not hidden.

A heavier, fully mechanical option (actual file-access tracing, e.g. wrapping execution with `strace`/equivalent to log real file opens) is noted as a future escalation path, only worth building if self-reporting proves insufficient in practice — consistent with how every other guardrail in this backlog defers heavier tooling until a concrete trigger shows up.

## Stepwise implementation plan (not yet executed)

1. Add a required "Context Manifest" subsection to the "Expected deliverables" section of every stage `CONTEXT.md` template: a short list of every file actually read, self-reported by the agent at the end of its work.
2. Add a line to `CRITICAL_ESCALATION.md` or the review process: the human reviewing a stage's output at the Obsidian gate cross-checks the Context Manifest against the `CONTEXT.md`'s declared `READ ONLY` scope; anything extra is a flag, not an automatic block (a human judgment call, since some extra reads may be legitimate and just under-declared in the contract).
3. Note explicitly in `docs/CONSTRAINTS.md` (0017) that this constraint is self-reported, not mechanically enforced, and why — so nobody mistakes it for a stronger guarantee than it is.
4. Test by scaffolding a sandbox feature, deliberately having a stage read one file outside its declared scope, and confirming the manifest makes that visible on review.
5. If this proves insufficient in practice (manifests are unreliable, or a real incident happens because of an unreported out-of-scope read), escalate to the heavier file-access-tracing option as its own future evolution entry — don't build it preemptively.

## What happens if adopted

Turns the framework's most important constraint from "the agent is asked to comply" into "the agent is asked to comply, and a human can actually check" — closing the gap between the claimed design guarantee and what's currently verifiable, at low implementation cost, while being honest that it's not a hard technical guarantee.
