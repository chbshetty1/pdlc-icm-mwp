# 0013 — Verify the Tooling Matrix Actually Works

- **Date:** 2026-07-09
- **Status:** adopted (2026-07-07)
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

## Stepwise implementation plan

**Correction (2026-07-09):** the original plan assumed CLI tools (Repomix, `graphifyy`, DuckDB, Mermaid CLI) could be verified from a sandboxed agent environment. Tried it — the sandbox's network is allowlisted and blocks both the npm registry and PyPI outright (`X-Proxy-Error: blocked-by-allowlist` on both `registry.npmjs.org` and `pypi.org`). So there is no sandbox-testable subset after all — **all six tools need verification on the user's own machine**, same as Fabric and Obsidian were already known to require. This is itself worth remembering: don't assume a sandboxed agent has general package-registry network access without checking first.

1. Repomix: `npm install -g repomix` (or `npx repomix`), run against this repo, confirm it produces a packed output file.
2. Graphify: `uv tool install graphifyy` or `pip install graphifyy --break-system-packages`, confirm the `graphify` command resolves and runs `graphify .` against a small test directory.
3. DuckDB: install via package manager, confirm a trivial `SELECT 1` query runs.
4. Mermaid CLI: `npm install -g @mermaid-js/mermaid-cli`, confirm `mmdc` renders a trivial diagram.
5. Fabric: requires a Go install or downloading a release binary and setting up patterns; verify manually.
6. Obsidian: a desktop GUI app — installation and vault setup can only be confirmed by opening it.
7. Update `TOOLING_MATRIX.md`'s install commands with whatever actually worked, and flag anything that failed or drifted from what's currently documented.

**Building the check mechanism itself:**
8. Write `scripts/doctor.sh`: default mode reports installed/missing for every tool in `TOOLING_MATRIX.md`, exits non-zero if anything's missing; `--install-missing` flag runs the documented install command only for missing tools, only when passed explicitly.
9. Add the per-stage lazy check to `CLAUDE.md`'s automation routing section: before each tool invocation, check `command -v`, and on failure write `BLOCKED_REASON.md` per `CRITICAL_ESCALATION.md` instead of attempting the run.
10. Test `doctor.sh` against whichever tools steps 1–6 confirmed are actually installed.

## What happens if adopted

Either confirms the tool matrix is accurate as documented (best case, close with no changes), or surfaces exactly which install command or tool name has drifted — before `CLAUDE.md`'s automation routing silently fails on a real feature run. This is foundational: entries that assume these tools work (none currently do directly, but future stage-automation work would) shouldn't be built on top of an unverified assumption.

## Progress (2026-07-09, in progress — not yet adopted)

- **Fabric: verified on Windows.** `winget install danielmiessler.Fabric` succeeded, but the `fabric` command wasn't recognized in a fresh PowerShell session — winget hadn't registered an App Execution Alias. Found the actual binary at `%LOCALAPPDATA%\Microsoft\WinGet\Packages\danielmiessler.Fabric_Microsoft.Winget.Source_8wekyb3d8bbwe\fabric.exe` and added that folder to the user `PATH` manually. This drift is now documented in `TOOLING_MATRIX.md`'s install column and as a general "Windows winget PATH gotcha" note there, since it likely isn't unique to Fabric.
- **Repomix: verified.** `npm install -g repomix` worked as documented — no changes needed.
- **Graphify: verified.** `uv tool install graphifyy` / `pipx install graphifyy` worked as documented — no changes needed.
- **DuckDB: verified, with a correction.** The documented install ("package manager or standalone binary") was a placeholder; the actual working install is `pip install duckdb`. `TOOLING_MATRIX.md` updated to state this directly.
- **Mermaid CLI: verified.** `npm install -g @mermaid-js/mermaid-cli` worked as documented — no changes needed.
- **Obsidian: verified.** Desktop app installed; vault set up via a directory junction linking this workspace into a separate primary vault. Indexes and renders the linked folder's contents normally (Mermaid code blocks render natively, no plugin needed). `TOOLING_MATRIX.md` updated with both the direct-vault and junction options.

All 6 of 6 tools confirmed (steps 1–7 of the plan above).

## Outcome (2026-07-07)

Steps 8–10 complete:

- **`scripts/doctor.sh` written and tested** (in a sandbox, since installing the actual tools requires the user's machine — same constraint noted in the Correction above). Default mode scans all five CLI tools (Obsidian is flagged `[manual]` — a GUI app, not checkable via `command -v`) and reports `[ok]`/`[missing]` per tool, exiting non-zero if anything's missing. Verified both branches: with no tools present, correctly listed all five as missing with their install commands and exited 1; with fake stand-in binaries on `PATH`, correctly reported all `[ok]` and exited 0.
- **`--install-missing` implemented as a deliberately narrower opt-in than originally scoped.** Only Repomix, Mermaid CLI, and DuckDB auto-install (single, non-interactive package-manager commands). Fabric and Graphify always print their install command instead of running it — both need an OS-specific choice or an interactive follow-up step (`fabric --setup`, `graphify install`) that shouldn't fire unattended. Verified in sandbox: the three auto-installable commands ran (network-blocked in-sandbox, as expected — see Correction above — but the script degraded correctly, printing a per-tool failure note and finishing with instructions to re-run and confirm, rather than crashing).
- **Lazy per-stage check wired into `CLAUDE.md`'s "Automated skill routing" section**: before invoking any tool, check `command -v`; on failure, write `BLOCKED_REASON.md` per `CRITICAL_ESCALATION.md` instead of attempting the run. `doctor.sh` also referenced in `CLAUDE.md`'s "Direct commands" and in `README.md`'s `scripts/` row.

No portability fixes needed beyond the narrowed auto-install scope above. `TOOLING_MATRIX.md` reflects reality end to end (all 6 tools, including Obsidian, marked verified with corrected install commands where they'd drifted).
