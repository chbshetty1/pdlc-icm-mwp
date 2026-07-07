#!/bin/bash
# On-demand check of the tool stack documented in docs/TOOLING_MATRIX.md.
#
# Two layers of tool checking exist in this framework (see docs/evolution/0013):
#   1. This script — a full, on-demand scan of every tool at once. A human
#      runs it whenever they want (after copying the framework into a new
#      product, or anytime something feels off). Never runs automatically.
#   2. A lazy per-stage check wired into CLAUDE.md's automation routing,
#      which checks one tool right before it's invoked and escalates via
#      BLOCKED_REASON.md if missing, instead of failing on a bare
#      "command not found" mid-task.
#
# Default mode only reports — nothing is installed. Passing --install-missing
# installs whatever it safely can (Repomix, Mermaid CLI, DuckDB: single,
# non-interactive package-manager commands). Fabric and Graphify always print
# their install command instead of auto-running it, since both need an
# OS-specific choice or an interactive follow-up step (fabric --setup,
# graphify install) that shouldn't run unattended.
set -euo pipefail

INSTALL_MISSING=false
if [ "${1:-}" = "--install-missing" ]; then
  INSTALL_MISSING=true
fi

# name | binary to check | install command shown to the human | auto-installable (true/false)
TOOLS=(
  "fabric|fabric|winget install danielmiessler.Fabric (Windows) or brew install fabric-ai (macOS/Linux), then run: fabric --setup|false"
  "graphify|graphify|uv tool install graphifyy (or pipx install graphifyy), then: graphify install|false"
  "repomix|repomix|npm install -g repomix|true"
  "mermaid-cli (mmdc)|mmdc|npm install -g @mermaid-js/mermaid-cli|true"
  "duckdb|duckdb|pip install duckdb|true"
)

MISSING_AUTO=()
MISSING_MANUAL=()

echo "Tooling check — see docs/TOOLING_MATRIX.md for details."
echo ""

for entry in "${TOOLS[@]}"; do
  IFS='|' read -r NAME BIN INSTALL_CMD AUTO <<< "$entry"
  if command -v "$BIN" >/dev/null 2>&1; then
    echo "  [ok]      $NAME"
  else
    echo "  [missing] $NAME  ->  $INSTALL_CMD"
    if [ "$AUTO" = "true" ]; then
      MISSING_AUTO+=("$NAME|$INSTALL_CMD")
    else
      MISSING_MANUAL+=("$NAME|$INSTALL_CMD")
    fi
  fi
done

echo "  [manual]  obsidian  ->  desktop GUI app, not checkable from the command line"
echo ""

TOTAL_MISSING=$(( ${#MISSING_AUTO[@]} + ${#MISSING_MANUAL[@]} ))

if [ "$TOTAL_MISSING" -eq 0 ]; then
  echo "All CLI tools installed."
  exit 0
fi

echo "$TOTAL_MISSING tool(s) missing."

if [ "$INSTALL_MISSING" = false ]; then
  echo "Run with --install-missing to install the ones that support it (repomix, mermaid CLI, duckdb)."
  echo "Fabric and Graphify always need a manual install — OS-specific or interactive setup steps."
  exit 1
fi

if [ ${#MISSING_MANUAL[@]} -gt 0 ]; then
  echo ""
  echo "The following need a manual install even with --install-missing (OS-specific or interactive):"
  for item in "${MISSING_MANUAL[@]}"; do
    IFS='|' read -r NAME INSTALL_CMD <<< "$item"
    echo "  $NAME  ->  $INSTALL_CMD"
  done
fi

if [ ${#MISSING_AUTO[@]} -eq 0 ]; then
  exit 1
fi

echo ""
echo "--install-missing passed. Installing:"
for item in "${MISSING_AUTO[@]}"; do
  IFS='|' read -r NAME INSTALL_CMD <<< "$item"
  echo ""
  echo "Installing $NAME: $INSTALL_CMD"
  eval "$INSTALL_CMD" || echo "  $NAME install failed — run manually: $INSTALL_CMD" >&2
done

echo ""
echo "Done. Re-run doctor.sh (without --install-missing) to confirm."
