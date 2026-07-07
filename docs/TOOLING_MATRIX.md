# Tooling Matrix

Free/open-source tools mapped to PDLC stages. Verify current install instructions before relying on any of these — versions and package names change.

| Tool | Category | Stage alignment | Role | Install (verify first) |
|---|---|---|---|---|
| [Obsidian](https://obsidian.md) | Workspace / knowledge UI | All stages | Human-in-the-loop review surface over the local file tree; point a vault at the workspace root. | Desktop app download |
| [Fabric](https://github.com/danielmiessler/fabric) | Unstructured text triage | 01_discovery_ideation, 02_definition_metrics | Pattern-based summarization of raw transcripts/notes before they enter context. | `go install` or release binary — check repo |
| [Graphify](https://github.com/safishamsi/graphify) | Knowledge graph / AST | 04_architecture_design | Turns code + docs into a queryable graph (`GRAPH_REPORT.md`), flags "god nodes" and structural risk before architecture changes. | PyPI package name is `graphifyy` (double-y); CLI command is `graphify`. `uv tool install graphifyy` or `pipx install graphifyy`, then `graphify install`. |
| [Repomix](https://repomix.com) | Context bundling | 05_development_test | Packs a repo/folder into a single AI-friendly, token-counted file; supports compression (~70% token reduction). | `npx repomix` or `npm install -g repomix` |
| [Mermaid CLI](https://github.com/mermaid-js/mermaid-cli) | Diagramming | 04_architecture_design | Renders architecture diagrams directly from markdown text blocks. | `npm install -g @mermaid-js/mermaid-cli` |
| [DuckDB](https://duckdb.org) | Data aggregation | 06_validation_gtm | Local SQL engine to pre-aggregate telemetry/logs before they ever reach model context. | package manager or standalone binary |

## Verification note

The 8-part brainstorming source for this framework flagged a naming collision ("Repo-Max" vs. "Repomix") and a package-name trap (`graphify` CLI vs. `graphifyy` PyPI package) — both are corrected in this table. Re-verify tool names/links periodically; this space moves fast and package names get squatted.
