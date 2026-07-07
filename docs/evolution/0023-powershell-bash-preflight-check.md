# 0023 — PowerShell-Native Bash Pre-Flight Check

- **Date:** 2026-07-09
- **Status:** adopted (2026-07-07)
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

## Outcome (2026-07-07)

Steps 1–2 done as planned: `scripts/preflight.ps1` written (`Get-Command bash -ErrorAction SilentlyContinue`; prints a green `[ok]` with the resolved path if found, or red `[missing]` plus both install options — Git for Windows via `winget install --id Git.Git -e --source winget` or `wsl --install` — and exits non-zero if not). `README.md`'s Prerequisites section updated to point to it as an optional first check.

Step 3 (testing) happened on the user's real machine, since this session's sandbox has no PowerShell at all — a harder limitation than entries 0003/0005/0009, where a bash sandbox was at least usable for real testing.

- **Found branch: confirmed directly.** `.\scripts\preflight.ps1` printed `[ok] bash found at C:\Windows\system32\bash.exe`.
- **Missing branch: adapted, then confirmed.** The original plan (step 3) suggested "temporarily renaming bash or checking a clean PATH" to simulate absence. Neither worked: `C:\Windows\System32\bash.exe` is a Windows-shipped WSL launcher stub that exists unconditionally on modern Windows — trimming `PATH` down to just `System32` still finds it, since that's exactly where it lives, and renaming a system binary isn't something worth asking a user to do just to test a doc script. Verified the branch logic instead by running an equivalent script pointed at a command guaranteed not to exist (`zzz-definitely-not-real`) — identical `Get-Command ... -ErrorAction SilentlyContinue` / if-else / red-text / `exit 1` shape as the real script, just aimed at something that can't be found. Got the red `[missing]` message and exit code `1` as expected.

**Worth recording as its own lesson:** on a modern Windows machine, "bash is completely absent" may not be a realistically testable state at all, since the WSL stub ships by default — this check's real value is likely narrower than the original problem statement assumed (catching an unset `PATH` or a broken install, not "bash was never touched"). Not a reason to drop the check, just a more honest scope for what it catches.
