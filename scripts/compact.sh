#!/bin/bash
# Context compaction for a growing feature/stage workspace.
# Requires a human (or Claude, on request) to have already written
# SUMMARY_SNAPSHOT.md summarizing current state before compacting.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck source=lib/log.sh
source "$SCRIPT_DIR/lib/log.sh"
trap 'LOG_EXIT_CODE=$?; log_invocation "$ROOT_DIR" "$(basename "$0")" "$*" "$LOG_EXIT_CODE"' EXIT

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  echo "Usage: $0 <workspace_path> [stage]"
  echo "Archive a stage's outputs/ except SUMMARY_SNAPSHOT.md, which must exist first."
  echo "Example: $0 features/FEAT-101_stripe 05_development_test"
  exit 0
fi

if [ $# -lt 1 ]; then
  echo "Usage: $0 <workspace_path> [stage]"
  echo "Example: $0 features/FEAT-101_stripe 05_development_test"
  exit 1
fi

WORKSPACE=$1
STAGE=${2:-}

TARGET="$WORKSPACE"
if [ -n "$STAGE" ]; then
  TARGET="$WORKSPACE/$STAGE"
fi

if [ ! -d "$TARGET/outputs" ]; then
  echo "Error: $TARGET/outputs not found." >&2
  exit 1
fi

SNAPSHOT="$TARGET/outputs/SUMMARY_SNAPSHOT.md"
if [ ! -f "$SNAPSHOT" ]; then
  echo "Error: $SNAPSHOT not found." >&2
  echo "  Have Claude generate a SUMMARY_SNAPSHOT.md of current state before compacting." >&2
  exit 1
fi

ARCHIVE_DIR="$TARGET/.archive/$(date +%Y%m%d%H%M%S)"
mkdir -p "$ARCHIVE_DIR"
for f in "$TARGET"/outputs/*; do
  base="$(basename "$f")"
  if [ "$base" == "SUMMARY_SNAPSHOT.md" ]; then
    continue
  fi
  mv "$f" "$ARCHIVE_DIR/"
done

echo "Compacted $TARGET/outputs -> $ARCHIVE_DIR (kept SUMMARY_SNAPSHOT.md)."
echo "Make sure Repomix/Graphify ignore rules exclude .archive/ so it never re-enters context."
