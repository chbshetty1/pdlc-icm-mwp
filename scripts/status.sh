#!/bin/bash
# On-demand status/monitoring scan across all active features and sprints.
# Reports two views from one scan: per-workspace and a stage-level rollup.
# No alerting, no daemon — checked when a human wants to know, nothing runs
# continuously. See docs/evolution/0016-status-monitoring-script.md.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck source=lib/scan_features.sh
source "$SCRIPT_DIR/lib/scan_features.sh"

STAGES=(01_discovery_ideation 02_definition_metrics 03_requirements_specs 04_architecture_design 05_development_test 06_validation_gtm)

print_section() {
  local base_dir="$1" label="$2"
  local dirs=()
  while IFS= read -r d; do dirs+=("$d"); done < <(list_workspace_dirs "$base_dir")

  if [ "${#dirs[@]}" -eq 0 ]; then
    return
  fi

  local -A STAGE_COUNT
  local -A STAGE_BLOCKED_COUNT
  local s
  for s in "${STAGES[@]}"; do
    STAGE_COUNT["$s"]=0
    STAGE_BLOCKED_COUNT["$s"]=0
  done

  echo "## $label"
  echo ""
  printf "%-30s %-25s %-9s %-25s %-20s\n" "Name" "Current stage" "Blocked" "Blocked at" "Last sync"
  printf "%-30s %-25s %-9s %-25s %-20s\n" "----" "-------------" "-------" "----------" "---------"

  local d NAME CURRENT_STAGE BLOCKED BLOCKED_STAGE OUT_DIR LAST_SYNC LAST_LINE
  for d in "${dirs[@]}"; do
    NAME="$(basename "$d")"
    CURRENT_STAGE="not started"
    BLOCKED="no"
    BLOCKED_STAGE=""

    for s in "${STAGES[@]}"; do
      OUT_DIR="$d/$s/outputs"
      if [ -d "$OUT_DIR" ]; then
        if [ -n "$(find "$OUT_DIR" -maxdepth 1 -type f 2>/dev/null)" ]; then
          CURRENT_STAGE="$s"
        fi
        if [ -f "$OUT_DIR/BLOCKED_REASON.md" ]; then
          BLOCKED="yes"
          BLOCKED_STAGE="$s"
        fi
      fi
    done

    if [ "$CURRENT_STAGE" != "not started" ]; then
      STAGE_COUNT["$CURRENT_STAGE"]=$(( STAGE_COUNT["$CURRENT_STAGE"] + 1 ))
      if [ "$BLOCKED" = "yes" ]; then
        STAGE_BLOCKED_COUNT["$CURRENT_STAGE"]=$(( STAGE_BLOCKED_COUNT["$CURRENT_STAGE"] + 1 ))
      fi
    fi

    LAST_SYNC="—"
    if [ -f "$d/SYNC_LOG.md" ]; then
      LAST_LINE="$(grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}' "$d/SYNC_LOG.md" 2>/dev/null | tail -1)"
      if [ -n "$LAST_LINE" ]; then
        LAST_SYNC="$(printf '%s' "$LAST_LINE" | awk -F' — ' '{print $1}')"
      fi
    fi

    printf "%-30s %-25s %-9s %-25s %-20s\n" "$NAME" "$CURRENT_STAGE" "$BLOCKED" "${BLOCKED_STAGE:-—}" "$LAST_SYNC"
  done

  echo ""
  echo "### Stage-level rollup"
  echo ""
  printf "%-25s %-10s %-10s\n" "Stage" "Active" "Blocked"
  printf "%-25s %-10s %-10s\n" "-----" "------" "-------"
  for s in "${STAGES[@]}"; do
    printf "%-25s %-10s %-10s\n" "$s" "${STAGE_COUNT[$s]}" "${STAGE_BLOCKED_COUNT[$s]}"
  done
  echo ""
}

print_section "$ROOT_DIR/features" "Features"
print_section "$ROOT_DIR/sprints" "Sprints"
