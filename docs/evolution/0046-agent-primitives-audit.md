# 0046 — Agent Primitives Audit: Skill Layers Gap Closed, Sub-Agents Deferred

- **Date:** 2026-07-10
- **Status:** adopted (2026-07-10)
- **Priority:** user-requested structural review ahead of the framework's first real end-to-end pilot — a pre-pilot check-in, not a reaction to a failure.

## Problem

Reviewed the shipped framework against 10 named agent primitives: instructions, context delivery, context management, tool interfaces, execution environments, durable state, orchestration, sub-agents, skill layers, and verification/observability. Eight already have dedicated, tested mechanisms (`IDENTITY.md`/`CLAUDE.md`/`CONTEXT.md` for instructions; declared `READ ONLY` scope + `sync.sh` for context delivery; token ceilings + `compact.sh` for context management; `TOOLING_MATRIX.md` + `doctor.sh` for tool interfaces; the Chat/Cowork/Code-CLI modality map for execution environments; `FEATURE_META.md`/`LEARNINGS.md`/`EVOLUTION_LOG.md`/the various `*_LOG.md` files for durable state; `scaffold.sh`/`sync.sh`/`pivot.sh`/`registry.sh` for orchestration; `PILOT_MEASUREMENT_PLAN.md`/`audit_manifest.sh`/`tests/` for verification and observability).

Two were thin or absent:

- **Sub-agents.** No delegation pattern exists. Entry `0001` frames concurrency as single-writer ownership, not folder isolation — one agent works one stage at a time, with a human gate at every transition. Whether that's a deliberate simplicity choice or a real gap hadn't been stated explicitly anywhere.
- **Skill layers.** Genuinely missing, and a real gap — not the same thing as `CLAUDE.md`'s "Automated skill routing" section, which is about CLI tools (fabric/graphify/repomix/duckdb). Claude's Skills (SKILL.md packages — docx/pptx/xlsx/pdf, etc.) are a distinct mechanism, already available in the Claude surfaces `CLAUDE_WORKFLOW_PLAYBOOK.md` recommends, and nothing in this framework maps which stage output would benefit from one.

## Decision

- **Skill layers: adopted.** A stage's polished, non-markdown deliverable (a stakeholder report, a deck, a tracker) is a cheap, documentation-only gap to close — add a mapping table, don't touch any script or `CONTEXT.md` contract.
- **Sub-agents: rejected-for-now**, not silently dropped. Building a delegation pattern before any pilot has generated data to justify it would repeat the exact mistake entry `0042` already caught once — adding machinery ahead of evidence, not in response to it. Revisit only if entry `0001`'s own trigger conditions fire; none have yet.
- **Verification & observability: adopted**, two small additions to `docs/PILOT_MEASUREMENT_PLAN.md` — one more free Tier 1 metric (stage-level turnaround, not just end-to-end lead time, computable from data the framework already writes), and closing the plan's previously-open "where do results get recorded" TODO, which turned out to be decidable now even though it can't be *executed* until a pilot repo exists.

## What happened

- `docs/TOOLING_MATRIX.md` — new "Claude Skills mapping" section, distinct from the existing CLI tool table, mapping stage output artifacts to docx/pptx/xlsx/pdf where a polished deliverable (not the working markdown artifact) is warranted. Travels with new products, same as the rest of the file.
- `docs/PILOT_MEASUREMENT_PLAN.md` — added a Tier 1 row ("Stage turnaround time, commit-to-commit") and closed the results-location TODO: decided `PILOT_METRICS.md` at the pilot repo's root, not folded into that repo's own evolution log, so results are findable without reading entry-by-entry. Framework-repo-only, as already established.
- `docs/FAQ.md` — two new entries: one distinguishing Claude Skills from `CLAUDE.md`'s CLI-tool "Automated skill routing," one explaining why sub-agent delegation isn't built and pointing to `0001`'s trigger conditions as the actual gate for revisiting it.
- `VERSION` bumped MINOR (20.9.0 → 20.10.0): `TOOLING_MATRIX.md` and `FAQ.md` both travel with new products (`0029`'s tiering rules).

## Outcome (2026-07-10)

Documentation-only change — no script or template logic touched, so no `template-version` bump and no test suite impact (confirmed: this entry doesn't add or change any `.mwp-templates/` file or `scripts/*.sh` behavior). The Skills mapping is a recommendation, not yet exercised against a real pilot — it should be spot-checked the first time a pilot stage actually needs a non-markdown deliverable, the same "trust but verify against a real case" discipline entries `0044`/`0045` already applied to Tier 2 instrumentation.
