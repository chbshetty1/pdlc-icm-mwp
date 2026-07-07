# Global Context

<!-- Copy to <product-repo>/.mwp/GLOBAL_CONTEXT.md and fill in before running scaffold.sh for the first feature. -->

## Product

- **Name:**
- **One-line description:**
- **Primary users:**

## Tech stack

- **Language(s)/framework:**
- **Data layer:**
- **Hosting/infra:**
- **Claude execution environment:** Claude Desktop / Claude Cowork / Claude Code CLI (name which, per `docs/CLAUDE_WORKFLOW_PLAYBOOK.md`)

## Global constraints

- Brand/style guidelines:
- Non-negotiable architectural rules (e.g. auth pattern, data residency):
- Token guardrail defaults: max 2500 tokens per stage-contract output unless a stage overrides it.

## Shared paths (collision detection)

<!-- Any path listed here is shared/global — a feature's 04_architecture_design
     or 05_development_test stage must never edit it directly from its
     isolated context (see "Shared Architecture Sync" in
     docs/CLAUDE_WORKFLOW_PLAYBOOK.md). scripts/sync.sh mechanically checks
     04_architecture_design/outputs/ and 05_development_test/src/ against
     this list at the 04->05 and 05->06 transitions, and refuses to sync
     (with an auto-filled BLOCKED_REASON.md) on any overlap. One path per
     line, exactly in this format. See docs/evolution/0005. -->

- shared_path: shared_schemas/

## Core Data Anchor status

<!-- Every workspace's first feature must be a Core Data Anchor (schemas, auth, shared types) that bypasses C-V-R scoring. Track it here. -->

| Anchor | Status | Path |
|---|---|---|
| e.g. Core DB schema + auth | not started | `./features/FEAT-001_core_architecture_and_schema` |

<!-- template-version: 2 -->
