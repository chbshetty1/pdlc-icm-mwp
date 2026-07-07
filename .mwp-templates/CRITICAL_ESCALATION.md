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
