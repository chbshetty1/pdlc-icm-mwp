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

## Core Data Anchor status

<!-- Every workspace's first feature must be a Core Data Anchor (schemas, auth, shared types) that bypasses C-V-R scoring. Track it here. -->

| Anchor | Status | Path |
|---|---|---|
| e.g. Core DB schema + auth | not started | `./features/FEAT-001_core_architecture_and_schema` |
