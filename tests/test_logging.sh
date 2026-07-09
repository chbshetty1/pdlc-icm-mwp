#!/bin/bash
# tests/test_logging.sh
# Regression test for entry 0014's $?-clobbering trap bug: a bad-usage call
# must log exit!=0 to .mwp/framework.log, not exit=0. This exact bug was
# caught only by manual sandbox testing during 0014's original adoption --
# this test exists so it can't silently regress if trap/log.sh is ever
# touched again without this specific check in mind.
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
LOG="$SCRATCH/.mwp/framework.log"

# --- Bad usage: scaffold.sh with no args must exit 1 AND log exit=1 ---
bash scripts/scaffold.sh >/dev/null 2>&1
assert_file_exists "$LOG" "framework.log created on first invocation"
LAST_LINE="$(tail -1 "$LOG")"
assert_contains "$LAST_LINE" "scaffold.sh" "log line names the script"
assert_not_contains "$LAST_LINE" "exit=0" "bad-usage call does NOT log exit=0 (the entry 0014 bug this guards against)"
assert_contains "$LAST_LINE" "exit=1" "bad-usage call logs exit=1"

# --- Good usage: a successful scaffold must log exit=0 ---
bash scripts/scaffold.sh --feature FEAT-001_test >/dev/null 2>&1
LAST_LINE2="$(tail -1 "$LOG")"
assert_contains "$LAST_LINE2" "exit=0" "successful call logs exit=0"

# --- Same check against sync.sh, since it has multiple scattered exit points ---
bash scripts/sync.sh >/dev/null 2>&1  # missing required args
LAST_LINE3="$(tail -1 "$LOG")"
assert_contains "$LAST_LINE3" "sync.sh" "log line names sync.sh"
assert_not_contains "$LAST_LINE3" "exit=0" "sync.sh bad-usage call does NOT log exit=0"

# --- Entry 0044 dry-run finding: exiting from INSIDE a function (not top-level
# script flow) must not blank the logged args. usage() (scaffold.sh) and
# check_secrets_guardrail() (sync.sh) are both called with no arguments of
# their own, so bash's $* inside them refers to their own empty positional
# parameters -- which used to leak into the EXIT trap and blank the real
# invocation args on exactly these failure paths. ---
bash scripts/scaffold.sh --feature >/dev/null 2>&1  # real arg present, but < 2 total -> usage()
LAST_LINE4="$(tail -1 "$LOG")"
assert_contains "$LAST_LINE4" "--feature" "scaffold.sh: real invocation arg survives an exit from inside usage() (entry 0044)"

FEATURE="features/FEAT-777_secret_leak"
bash scripts/scaffold.sh --feature FEAT-777_secret_leak >/dev/null 2>&1
printf 'access_key = %s\n' "not-a-real-secret-1234567890" > "$FEATURE/01_discovery_ideation/outputs/Leak.md"
bash scripts/sync.sh "$FEATURE" 01_discovery_ideation 02_definition_metrics "Tester" >/dev/null 2>&1
LAST_LINE5="$(tail -1 "$LOG")"
assert_contains "$LAST_LINE5" "$FEATURE" "sync.sh: real invocation args survive an exit from inside check_secrets_guardrail() (entry 0044)"
assert_contains "$LAST_LINE5" "exit=1" "sync.sh: the secrets-block exit is still logged as a failure"

echo "SUMMARY: $TESTS_RUN run, $TESTS_FAILED failed"
exit "$TESTS_FAILED"
