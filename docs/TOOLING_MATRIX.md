# Tooling Matrix

Free/open-source tools mapped to PDLC stages. Verify current install instructions before relying on any of these — versions and package names change.

| Tool | Category | Stage alignment | Role | Install (verify first) |
|---|---|---|---|---|
| [Obsidian](https://obsidian.md) | Workspace / knowledge UI | All stages | Human-in-the-loop review surface over the local file tree; point a vault at the workspace root. | **Verified:** Desktop app download. Can point a vault directly at a workspace root, or link a workspace in via a directory junction (Windows: `New-Item -ItemType Junction`) if you keep a separate primary vault — either way Obsidian indexes and renders it (including Mermaid code blocks) with no plugin needed. |
| [Fabric](https://github.com/danielmiessler/fabric) | Unstructured text triage | 01_discovery_ideation, 02_definition_metrics | Pattern-based summarization of raw transcripts/notes before they enter context. | **Windows (verified):** `winget install danielmiessler.Fabric`, then run `fabric --setup` once to configure a model/API key. **macOS/Linux:** `brew install fabric-ai` or the install-script one-liner in the repo README. |
| [Graphify](https://github.com/safishamsi/graphify) | Knowledge graph / AST | 04_architecture_design | Turns code + docs into a queryable graph (`GRAPH_REPORT.md`), flags "god nodes" and structural risk before architecture changes. | **Verified:** PyPI package name is `graphifyy` (double-y); CLI command is `graphify`. `uv tool install graphifyy` or `pipx install graphifyy`, then `graphify install`. |
| [Repomix](https://repomix.com) | Context bundling | 05_development_test | Packs a repo/folder into a single AI-friendly, token-counted file; supports compression (~70% token reduction). | **Verified:** `npx repomix` or `npm install -g repomix` |
| [Mermaid CLI](https://github.com/mermaid-js/mermaid-cli) | Diagramming | 04_architecture_design | Renders architecture diagrams directly from markdown text blocks. | **Verified:** `npm install -g @mermaid-js/mermaid-cli` |
| [DuckDB](https://duckdb.org) | Data aggregation | 06_validation_gtm | Local SQL engine to pre-aggregate telemetry/logs before they ever reach model context. | **Verified:** `pip install duckdb` (corrected from the original "package manager or standalone binary" placeholder). |

## Verification note

The 8-part brainstorming source for this framework flagged a naming collision ("Repo-Max" vs. "Repomix") and a package-name trap (`graphify` CLI vs. `graphifyy` PyPI package) — both are corrected in this table. Re-verify tool names/links periodically; this space moves fast and package names get squatted.

**Windows winget PATH gotcha (found verifying Fabric):** `winget install` doesn't always register an App Execution Alias, so the installed command can be unrecognized in a fresh terminal even though installation succeeded. If a `winget`-installed tool isn't found, locate the actual `.exe` under `%LOCALAPPDATA%\Microsoft\WinGet\Packages\<PackageId>_...\` and add that folder to your user PATH:

```powershell
$toolPath = "C:\path\to\the\package\folder"
$currentUserPath = [Environment]::GetEnvironmentVariable("PATH", "User")
[Environment]::SetEnvironmentVariable("PATH", "$currentUserPath;$toolPath", "User")
```

Open a new terminal afterward — this doesn't affect the current session. Worth checking for any other tool in this table installed via `winget`, not just Fabric.

## Claude Skills mapping (output-format packaging)

Distinct from the tool table above, and distinct from `CLAUDE.md`'s "Automated skill routing" section — both of those are about CLI tools (Fabric, Graphify, Repomix, DuckDB) that transform or compress text before it enters context. This section is about Claude's Skills (reusable `SKILL.md` packages — docx, pptx, xlsx, pdf, etc.) available in Claude surfaces like Cowork: which stage output artifact is worth turning into a polished, non-markdown deliverable, and with which skill, if a real deliverable is actually needed.

| Stage | Output artifact | Skill | When to use it |
|---|---|---|---|
| 02_definition_metrics | `Core_Metrics_KPIs.md` | xlsx | A stakeholder wants a computable KPI tracker, not a static table. |
| 03_requirements_specs / 04_architecture_design | `BDD_Gherkin_Specs.md`, `System_Architecture.md` | docx | The spec or architecture doc needs to leave the workspace as a reviewable Word file — e.g. for a non-technical stakeholder. |
| 04_architecture_design | `System_Architecture.md` and its diagrams | pptx | Architecture needs to be presented, not just read — on top of, not instead of, the Mermaid diagrams `CLAUDE.md` already requires. |
| 06_validation_gtm | `Validation_Report.md` | pdf or docx | The final pilot/validation report needs to leave the workspace as a shareable, fixed-layout document. |

Notes:

- Applies only when a stage's output needs to leave the workspace as a polished deliverable. The working artifact inside a stage's own `outputs/` stays plain markdown, same as everywhere else in this framework — cheapest thing satisfying "human-readable" and "machine-parseable" at once, per `docs/evolution/0001-first-principles-analysis.md`.
- Optional, same status as the rest of this file's tool stack — no `CONTEXT.md` contract requires it, and no script checks whether it was used.
- A human requests the polished deliverable at the point they need it; this is a mapping of which skill fits which artifact, not a new automated step in `sync.sh` or `scaffold.sh`. See `docs/evolution/0046-agent-primitives-audit.md`.
