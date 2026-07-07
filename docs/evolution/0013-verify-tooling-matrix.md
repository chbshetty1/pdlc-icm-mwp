# 0013 — Verify the Tooling Matrix Actually Works

- **Date:** 2026-07-09
- **Status:** proposed
- **Priority:** high — same class of gap as 0002 (infrastructure assumed but never verified), applied to the external tool stack instead of the bash scripts.

## Problem

`docs/TOOLING_MATRIX.md` documents which tools support which stage (Fabric for 01/02, Graphify for 04, Repomix for 05, DuckDB for 06, Obsidian throughout) and even says outright: "verify current install instructions before relying on any of these." Nobody has. `CLAUDE.md`'s automation routing instructs Claude Code to run `fabric`, `graphify`, `repomix`, and `duckdb` at specific stages on the assumption they're installed — if any aren't, those instructions fail silently (command not found) the first time a real feature reaches that stage, with no fallback defined.

## Proposed change

Actually install and run each tool once, confirm the exact commands in `TOOLING_MATRIX.md` and `CLAUDE.md` work as documented, and fix anything that's drifted (package names change — this framework's own source material already caught one such drift, "Repo-Max" vs. Repomix, and the `graphify`/`graphifyy` naming trap).

Beyond the one-time verification, formalize *when and how* the framework checks for these tools going forward — this was worked out as a follow-up design discussion and folded in here rather than as a separate entry:

### When the framework checks (two layers, not one)

1. **On-demand, full check** — a new `scripts/doctor.sh` that scans the whole `TOOLING_MATRIX.md` stack at once (`command -v` for each CLI tool). A human runs this whenever they want — right after copying the framework into a new product, or anytime something feels off. Never runs automatically or silently.
2. **Lazy, per-stage check** — before `CLAUDE.md`'s automation routing invokes a tool for a given stage (`fabric` in 01/02, `graphify` in 04, `repomix` in 05, `duckdb` in 06), a cheap `command -v <tool>` check happens first. If missing, don't attempt the run and fail with a cryptic "command not found" — instead reuse the existing escalation machinery: write `BLOCKED_REASON.md` per `CRITICAL_ESCALATION.md`, with the message pointing at the exact install command from `TOOLING_MATRIX.md`.

**Explicitly not** a hard gate in `scaffold.sh` — creating a feature workspace should never be blocked because a stage-04-only tool isn't installed yet when the feature might not reach stage 04 for a while.

### Should it auto-install missing tools? No, by default.

Installing software is a meaningfully bigger side effect than anything else this framework does — everything else is scoped to reading/writing markdown in a declared folder; auto-running `npm install -g` or `pip install` modifies the host environment, needs network access, and can conflict with other projects. That's exactly the category of decision the escalation contract exists for: detect, stop, tell a human exactly what to run, let them decide — not silently self-heal by installing things unprompted.

**Opt-in convenience, not a default:** `doctor.sh --install-missing` runs the install commands from `TOOLING_MATRIX.md` for anything missing, but only when a human explicitly passes that flag. Without it, `doctor.sh` only reports.

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

**Building the check mechanism itself:**
8. Write `scripts/doctor.sh`: default mode reports installed/missing for every tool in `TOOLING_MATRIX.md`, exits non-zero if anything's missing; `--install-missing` flag runs the documented install command only for missing tools, only when passed explicitly.
9. Add the per-stage lazy check to `CLAUDE.md`'s automation routing section: before each tool invocation, check `command -v`, and on failure write `BLOCKED_REASON.md` per `CRITICAL_ESCALATION.md` instead of attempting the run.
10. Test `doctor.sh` in both modes against the sandbox once steps 1–4 confirm which tools are actually installable there.

## What happens if adopted

Either confirms the tool matrix is accurate as documented (best case, close with no changes), or surfaces exactly which install command or tool name has drifted — before `CLAUDE.md`'s automation routing silently fails on a real feature run. This is foundational: entries that assume these tools work (none currently do directly, but future stage-automation work would) shouldn't be built on top of an unverified assumption.
