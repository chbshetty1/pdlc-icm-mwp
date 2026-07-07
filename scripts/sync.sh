#!/bin/bash
# Advance approved outputs from one stage into the next stage's inputs.
# Keeps stage folders strictly local-scoped (no leaky ../../ relative reads
# from inside CONTEXT.md prompts).
set -euo pipefail

if [ $# -lt 3 ]; then
  echo "Usage: $0 <workspace_path> <from_stage> <to_stage>"
  echo "Example: $0 features/FEAT-101_stripe 01_discovery_ideation 02_definition_metrics"
  exit 1
fi

WORKSPACE=$1
FROM=$2
TO=$3

FROM_OUT="$WORKSPACE/$FROM/outputs"
TO_IN="$WORKSPACE/$TO/inputs"

if [ ! -d "$FROM_OUT" ]; then
  echo "Error: $FROM_OUT does not exist." >&2
  exit 1
fi

if [ -f "$FROM_OUT/BLOCKED_REASON.md" ]; then
  echo "Error: $FROM/outputs contains an unresolved BLOCKED_REASON.md. Resolve it before syncing forward." >&2
  exit 1
fi

mkdir -p "$TO_IN"
cp -r "$FROM_OUT"/. "$TO_IN"/
echo "Synced $FROM_OUT -> $TO_IN"
