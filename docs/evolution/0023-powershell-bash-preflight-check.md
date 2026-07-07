# 0023 — PowerShell-Native Bash Pre-Flight Check

- **Date:** 2026-07-09
- **Status:** proposed
- **Priority:** see entry 0024 (ranking update).

## Problem

Entry 0002 verified `scripts/*.sh` work correctly from Git Bash. But nothing detects the case where someone tries to run them *without* Git Bash or WSL installed at all — and nothing in this framework *can* detect that from the inside: `doctor.sh` (0013) is itself a bash script, so if bash doesn't exist, nothing here ever starts running to report the problem. The only failure signal in that case is PowerShell's own external "command not found," outside this framework's control. The README prerequisite note (added when 0002 was adopted) is the only mitigation today, and it only helps if read in advance.

## Proposed change

A small, standalone PowerShell script (`scripts/preflight.ps1`) that can be run *from PowerShell, before ever attempting a bash script* — checks whether `bash` resolves on PATH (Git Bash or WSL), and if not, prints clear guidance (install Git for Windows, or enable WSL) rather than letting the user hit a raw "command not found." Detection and guidance only — same no-auto-install stance as everything else in this backlog; it never installs Git Bash or WSL on your behalf.

## Stepwise implementation plan (not yet executed)

1. Write `scripts/preflight.ps1`: check `Get-Command bash -ErrorAction SilentlyContinue`; if found, print confirmation; if not, print the two install options (Git for Windows, `wsl --install`) and exit non-zero.
2. Add a line to `README.md`'s Prerequisites section pointing to it as an optional first check for Windows users.
3. Test on the actual machine this framework is used on, both with and without simulating bash's absence (e.g., temporarily renaming it or checking a clean PATH) to confirm both branches print correctly.

## What happens if adopted

Closes the one prerequisite gap that can't be caught by `doctor.sh` itself, since `doctor.sh` requires the very thing being checked for. Cheap, and prevents a confusing raw shell error for anyone new to this framework on Windows.
