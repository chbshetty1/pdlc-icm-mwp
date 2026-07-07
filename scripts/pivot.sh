#!/bin/bash
# Lean Pivot/Persevere control for a Micro-PDLC feature.
set -euo pipefail

if [ $# -lt 2 ]; then
  echo "Usage: $0 <FEATURE_NAME> --pivot|--persevere"
  exit 1
fi

FEATURE_NAME=$1
ACTION=$2
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
FEATURE_DIR="$ROOT_DIR/features/$FEATURE_NAME"

if [ ! -d "$FEATURE_DIR" ]; then
  echo "Error: $FEATURE_DIR not found." >&2
  exit 1
fi

case "$ACTION" in
  --pivot)
    echo "Hypothesis invalidated for $FEATURE_NAME. Archiving learnings, purging workspace..."
    ARCHIVE_DIR="$ROOT_DIR/.archive/failed_hypotheses/$FEATURE_NAME"
    mkdir -p "$ARCHIVE_DIR"
    [ -d "$FEATURE_DIR/01_discovery_ideation" ] && mv "$FEATURE_DIR/01_discovery_ideation" "$ARCHIVE_DIR/"
    [ -d "$FEATURE_DIR/02_definition_metrics" ] && mv "$FEATURE_DIR/02_definition_metrics" "$ARCHIVE_DIR/"
    rm -rf "$FEATURE_DIR"
    echo "Archived discovery/metrics learnings to $ARCHIVE_DIR."
    echo "Purged specs/architecture/code for $FEATURE_NAME so it never pollutes future context."
    echo "Remember to update its Status to PIVOTED in .mwp/FEATURE_PRIORITY_REGISTRY.md."
    ;;
  --persevere)
    echo "$FEATURE_NAME persevered. No files changed; proceed to the next stage or ship."
    ;;
  *)
    echo "Unknown action: $ACTION" >&2
    exit 1
    ;;
esac
