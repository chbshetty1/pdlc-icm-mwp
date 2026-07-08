#!/bin/bash
# tests/test_secrets_guardrail.sh
# Covers entry 0034: sync.sh's secrets/credential guardrail. Confirms it
# blocks on the shapes it's meant to catch (private-key block, AWS-shaped
# access key ID, generic hardcoded key/secret/password/token assignment,
# a credential-shaped filename), does NOT false-positive on an obvious
# template placeholder, and does not disturb a clean sync.
set -uo pipefail
TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="${ROOT_DIR:-$(cd "$TESTS_DIR/.." && pwd)}"
# shellcheck source=lib/assert.sh
source "$TESTS_DIR/lib/assert.sh"

SCRATCH="$(mktemp -d)"
trap 'rm -rf "$SCRATCH"' EXIT

cp -r "$ROOT_DIR/scripts" "$SCRATCH/scripts"
cp -r "$ROOT_DIR/.mwp-templates" "$SCRATCH/.mwp-templates"
cd "$SCRATCH" || exit 1
bash scripts/scaffold.sh --feature FEAT-001_test >/dev/null 2>&1
FEATURE="features/FEAT-001_test"
FROM_OUT="$FEATURE/01_discovery_ideation/outputs"

run_sync() {
  bash scripts/sync.sh "$FEATURE" 01_discovery_ideation 02_definition_metrics 2>&1
}

# --- Clean output: sync proceeds normally ---
echo "just some ordinary discovery notes" > "$FROM_OUT/Notes.md"
set +e
OUT_CLEAN="$(run_sync)"
EC_CLEAN=$?
set -e
assert_equal "0" "$EC_CLEAN" "clean stage output syncs normally (no false positive)"
assert_file_exists "features/FEAT-001_test/02_definition_metrics/inputs/Notes.md" "clean file was copied through"
rm -f "$FROM_OUT"/*

# --- Private key block: blocked ---
{
  echo "-----BEGIN RSA PRIVATE KEY-----"
  echo "MIIEpAIBAAKCAQEA1234567890abcdefgh"
  echo "-----END RSA PRIVATE KEY-----"
} > "$FROM_OUT/Leaked.md"
set +e
OUT_PK="$(run_sync)"
EC_PK=$?
set -e
assert_equal "1" "$EC_PK" "private-key block in output blocks the sync"
assert_file_exists "$FROM_OUT/BLOCKED_REASON.md" "BLOCKED_REASON.md auto-written for private-key block"
assert_file_contains "$FROM_OUT/BLOCKED_REASON.md" "PRIVATE KEY" "BLOCKED_REASON.md names the private-key finding"
rm -f "$FROM_OUT/Leaked.md" "$FROM_OUT/BLOCKED_REASON.md"

# --- AWS-shaped access key ID: blocked ---
echo "aws_key = AKIAABCDEFGHIJKLMNOP" > "$FROM_OUT/Config.md"
set +e
OUT_AWS="$(run_sync)"
EC_AWS=$?
set -e
assert_equal "1" "$EC_AWS" "AWS-shaped access key ID blocks the sync"
assert_file_contains "$FROM_OUT/BLOCKED_REASON.md" "AWS access key" "BLOCKED_REASON.md names the AWS-key finding"
rm -f "$FROM_OUT/Config.md" "$FROM_OUT/BLOCKED_REASON.md"

# --- Generic hardcoded credential assignment: blocked ---
echo "api_key: not-a-real-secret-1234567890" > "$FROM_OUT/Env_Notes.md"
set +e
OUT_GEN="$(run_sync)"
EC_GEN=$?
set -e
assert_equal "1" "$EC_GEN" "generic hardcoded api_key assignment blocks the sync"
assert_file_contains "$FROM_OUT/BLOCKED_REASON.md" "hardcoded credential" "BLOCKED_REASON.md names the generic-credential finding"
rm -f "$FROM_OUT/Env_Notes.md" "$FROM_OUT/BLOCKED_REASON.md"

# --- Credential-shaped filename alone: blocked, even with harmless content ---
echo "not actually a key" > "$FROM_OUT/id_rsa"
set +e
OUT_FN="$(run_sync)"
EC_FN=$?
set -e
assert_equal "1" "$EC_FN" "a file literally named id_rsa blocks the sync regardless of content"
rm -f "$FROM_OUT/id_rsa" "$FROM_OUT/BLOCKED_REASON.md"

# --- Placeholder value: NOT blocked (false-positive avoidance) ---
echo "api_key: {{API_KEY}}" > "$FROM_OUT/Template_Notes.md"
set +e
OUT_PH="$(run_sync)"
EC_PH=$?
set -e
assert_equal "0" "$EC_PH" "a {{PLACEHOLDER}} value for api_key does NOT block the sync"
rm -f "$FROM_OUT/Template_Notes.md"
rm -rf "features/FEAT-001_test/02_definition_metrics/inputs"/*

echo "SUMMARY: $TESTS_RUN run, $TESTS_FAILED failed"
exit "$TESTS_FAILED"
