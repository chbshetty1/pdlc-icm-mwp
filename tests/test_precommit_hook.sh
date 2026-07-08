#!/bin/bash
# tests/test_precommit_hook.sh
# Covers entry 0040: hooks/pre-commit, a sample git hook reusing sync.sh's
# secrets-guardrail patterns (entry 0034) against staged files. Confirms it
# blocks a commit containing a credential-shaped string, allows a clean
# commit, allows a {{PLACEHOLDER}}-style value through, and can be bypassed
# with --no-verify as documented.
set -uo pipefail
TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="${ROOT_DIR:-$(cd "$TESTS_DIR/.." && pwd)}"
# shellcheck source=lib/assert.sh
source "$TESTS_DIR/lib/assert.sh"

SCRATCH="$(mktemp -d)"
trap 'rm -rf "$SCRATCH"' EXIT

cd "$SCRATCH" || exit 1
git init -q
git config user.email "test@example.com"
git config user.name "Test"

mkdir -p .git/hooks
cp "$ROOT_DIR/hooks/pre-commit" .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit

# --- Clean commit succeeds ---
echo "just some ordinary notes" > Notes.md
git add Notes.md
set +e
git commit -q -m "clean commit" >/tmp/precommit_clean_out 2>&1
CLEAN_EC=$?
set -e
assert_equal "0" "$CLEAN_EC" "clean staged file commits successfully"

# --- Private key block blocks the commit ---
{
  echo "-----BEGIN RSA PRIVATE KEY-----"
  echo "MIIEpAIBAAKCAQEA1234567890abcdefgh"
  echo "-----END RSA PRIVATE KEY-----"
} > Leaked.md
git add Leaked.md
set +e
OUT_PK="$(git commit -q -m "leaked key" 2>&1)"
PK_EC=$?
set -e
assert_equal "1" "$PK_EC" "private-key block in a staged file blocks the commit"
assert_contains "$OUT_PK" "PRIVATE KEY" "hook output names the private-key finding"
git reset -q Leaked.md
rm -f Leaked.md

# --- Generic hardcoded credential blocks the commit ---
echo "api_key: not-a-real-secret-1234567890" > Env_Notes.md
git add Env_Notes.md
set +e
OUT_GEN="$(git commit -q -m "hardcoded credential" 2>&1)"
GEN_EC=$?
set -e
assert_equal "1" "$GEN_EC" "generic hardcoded api_key assignment blocks the commit"
git reset -q Env_Notes.md
rm -f Env_Notes.md

# --- Placeholder value does NOT block the commit ---
echo "api_key: {{API_KEY}}" > Template_Notes.md
git add Template_Notes.md
set +e
git commit -q -m "placeholder value" >/tmp/precommit_ph_out 2>&1
PH_EC=$?
set -e
assert_equal "0" "$PH_EC" "a {{PLACEHOLDER}} value does NOT block the commit"

# --- --no-verify bypasses the hook ---
{
  echo "-----BEGIN RSA PRIVATE KEY-----"
  echo "MIIEpAIBAAKCAQEA1234567890abcdefgh"
  echo "-----END RSA PRIVATE KEY-----"
} > Bypassed.md
git add Bypassed.md
set +e
git commit -q -m "bypassed" --no-verify >/tmp/precommit_bypass_out 2>&1
BYPASS_EC=$?
set -e
assert_equal "0" "$BYPASS_EC" "git commit --no-verify bypasses the hook as documented"

echo "SUMMARY: $TESTS_RUN run, $TESTS_FAILED failed"
exit "$TESTS_FAILED"
