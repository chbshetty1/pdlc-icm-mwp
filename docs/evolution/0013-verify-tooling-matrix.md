# 0013 — Verify the Tooling Matrix Actually Works

- **Date:** 2026-07-09
- **Status:** proposed
- **Priority:** high — same class of gap as 0002 (infrastructure assumed but never verified), applied to the external tool stack instead of the bash scripts.

## Problem

`docs/TOOLING_MATRIX.md` documents which tools support which stage (Fabric for 01/02, Graphify for 04, Repomix for 05, DuckDB for 06, Obsidian throughout) and even says outright: "verify current install instructions before relying on any of these." Nobody has. `CLAUDE.md`'s automation routing instructs Claude Code to run `fabric`, `graphify`, `repomix`, and `duckdb` at specific stages on the assumption they're installed — if any aren't, those instructions fail silently (command not found) the first time a real feature reaches that stage, with no fallback defined.

## Proposed change

Actually install and run each tool once, confirm the exact commands in `TOOLING_MATRIX.md` and `CLAUDE.md` work as documented, and fix anything that's drifted (package names change — this framework's own source material already caught one such drift, "Repo-Max" vs. Repomix, and the `graphify`/`graphifyy` naming trap).

## Stepwise implementation plan (not yet executed)

Split by what's actually testable where:

**Sandbox-testable (CLI tools, no GUI, no interactive auth):**
1. Repomix: `npm install -g repomix` (or `npx repomix`), run against this repo, confirm it produces a packed output file.
2. Graphify: `uv tool install graphifyy` or `pip install graphifyy --break-system-packages`, confirm the `graphify` command resolves and runs `graphify .` against a small test directory.
3. DuckDB: install via package manager, confirm a trivial `SELECT 1` query runs.
4. Mermaid CLI: `npm install -g @mermaid-js/mermaid-cli`, confirm `mmdc` renders a trivial diagram.
5. Update `TOOLING_MATRIX.md`'s install commands with whatever actually worked, and flag anything that failed or drifted from what's currently documented.

**Not sandbox-testable — needs the user's own machine:**
6. Fabric: requires a Go install or downloading a release binary and setting up patterns; verify manually and report back what worked.
7. Obsidian: a desktop GUI app — installation and vault setup can only be confirmed by opening it, not from a headless environment.

## What happens if adopted

Either confirms the tool matrix is accurate as documented (best case, close with no changes), or surfaces exactly which install command or tool name has drifted — before `CLAUDE.md`'s automation routing silently fails on a real feature run. This is foundational: entries that assume these tools work (none currently do directly, but future stage-automation work would) shouldn't be built on top of an unverified assumption.
