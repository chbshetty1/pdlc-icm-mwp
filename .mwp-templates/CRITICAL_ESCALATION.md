# Escalation Contract

Every stage `CONTEXT.md` references this file under "On failure." When triggered, an agent must stop and write a `BLOCKED_REASON.md` into the active stage's `outputs/` directory using this exact structure, then end the session. Do not attempt a third automated fix.

## Trigger conditions

- A test suite or validation script fails twice consecutively for the same reason.
- A stage's required upstream input file is missing or contradicts an earlier locked artifact (e.g. a spec that violates `OKR_Framework.md`).
- A proposed change would modify a shared/global schema or component also used by another active feature (see Shared Architecture Sync).
- The agent cannot produce a falsifiable/measurable output after two attempts (stages 01–02).

## BLOCKED_REASON.md template

```markdown
# BLOCKED: {{FEATURE_NAME}} / {{STAGE}}

## What was attempted
(1-2 sentences)

## Why it failed
(the specific error, contradiction, or conflict — quote it)

## Attempts made
1.
2.

## What a human needs to decide
(the specific question that requires human judgment)

## Suggested next step
(optional — the agent's best guess, clearly labeled as a suggestion)
```

## Human resolution

A human reviews `BLOCKED_REASON.md` in Obsidian, resolves the underlying issue (edits an upstream file, makes an architectural call, adjusts scope), deletes or archives the `BLOCKED_REASON.md`, and re-runs the stage. This file existing in `outputs/` is itself the signal that a stage is paused — automation should treat its presence as a hard stop.

## Context Manifest cross-check

Every stage's `outputs/` also includes a self-reported `Context_Manifest.md` (every file the agent actually read, per that stage's `CONTEXT.md`). At the same Obsidian review gate as everything else, a human cross-checks the manifest against the contract's declared `READ ONLY` scope. Anything extra is a **flag, not an automatic block** — some extra reads may be legitimate and just under-declared in the contract; that's a human judgment call, not grounds for an automated stop.

**This is not mechanical enforcement.** The manifest is self-reported by the agent, not traced at the OS/file-access level — an agent could in principle read outside scope and omit it from the manifest. This makes the framework's most load-bearing constraint (directory containment) *visible and auditable* rather than purely trust-based, but it is not a hard technical guarantee. If self-reporting proves unreliable in practice, the next step is actual file-access tracing (e.g. wrapping execution with `strace`/equivalent) — that's deliberately not built yet, as a future evolution entry only if a concrete need shows up. *(This note is the interim home for this disclosure; once `docs/CONSTRAINTS.md` exists — entry 0017 — it belongs there instead, alongside the framework's other non-negotiables.)*

See `docs/evolution/0018-scope-containment-verification.md`.

<!-- template-version: 2 -->
