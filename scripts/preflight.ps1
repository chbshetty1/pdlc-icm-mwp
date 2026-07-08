# scripts/preflight.ps1
# Standalone check, runnable from plain PowerShell, for whether bash
# (Git Bash or WSL) is available before attempting any scripts/*.sh file.
# Detection and guidance only -- never installs anything automatically,
# same no-auto-install stance as the rest of this framework's tooling.
# See docs/evolution/0023-powershell-bash-preflight-check.md.

$bash = Get-Command bash -ErrorAction SilentlyContinue

if ($bash) {
    Write-Host "[ok] bash found at $($bash.Source)" -ForegroundColor Green
    Write-Host "You're set to run scripts/*.sh (scaffold.sh, sync.sh, pivot.sh, compact.sh, doctor.sh, registry.sh) from Git Bash or an equivalent bash on PATH."
    exit 0
}
else {
    Write-Host "[missing] bash was not found on PATH." -ForegroundColor Red
    Write-Host ""
    Write-Host "scripts/*.sh require a bash shell -- plain PowerShell or cmd cannot run them directly."
    Write-Host "Install one of the following, then re-run this check:"
    Write-Host ""
    Write-Host "  Option 1 - Git for Windows (includes Git Bash):"
    Write-Host "    winget install --id Git.Git -e --source winget"
    Write-Host "    or download manually: https://git-scm.com/download/win"
    Write-Host ""
    Write-Host "  Option 2 - Windows Subsystem for Linux (WSL):"
    Write-Host "    wsl --install"
    Write-Host ""
    Write-Host "Open a new terminal after installing either option, then re-run: .\scripts\preflight.ps1"
    exit 1
}
