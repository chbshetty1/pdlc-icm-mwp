#!/bin/bash
# tests/lib/assert.sh
# Minimal, dependency-free assertion helpers for tests/test_*.sh.
#
# No external test framework (no bats-core) -- see
# docs/evolution/0030-script-test-harness.md for why: bats-core needs
# root/network to install in some environments (confirmed while building
# this) and would add a new cross-platform install requirement this
# framework otherwise avoids -- every scripts/*.sh file already runs on
# plain bash alone. These helpers need nothing beyond that same bash.
#
# Each test_*.sh file sources this, runs assertions, then must end with:
#   echo "SUMMARY: $TESTS_RUN run, $TESTS_FAILED failed"
#   exit "$TESTS_FAILED"
# so tests/run_tests.sh (which runs each file as its own subprocess) can
# parse the result without any shared state between suites.

TESTS_RUN=0
TESTS_FAILED=0

assert_equal() {
  local expected="$1" actual="$2" msg="${3:-assert_equal}"
  TESTS_RUN=$((TESTS_RUN + 1))
  if [ "$expected" != "$actual" ]; then
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo "  FAIL: $msg -- expected [$expected], got [$actual]"
    return 1
  fi
  echo "  ok: $msg"
}

assert_file_exists() {
  local path="$1" msg="${2:-file exists: $path}"
  TESTS_RUN=$((TESTS_RUN + 1))
  if [ ! -f "$path" ]; then
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo "  FAIL: $msg"
    return 1
  fi
  echo "  ok: $msg"
}

assert_file_not_exists() {
  local path="$1" msg="${2:-file does not exist: $path}"
  TESTS_RUN=$((TESTS_RUN + 1))
  if [ -f "$path" ]; then
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo "  FAIL: $msg"
    return 1
  fi
  echo "  ok: $msg"
}

assert_dir_exists() {
  local path="$1" msg="${2:-dir exists: $path}"
  TESTS_RUN=$((TESTS_RUN + 1))
  if [ ! -d "$path" ]; then
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo "  FAIL: $msg"
    return 1
  fi
  echo "  ok: $msg"
}

assert_dir_not_exists() {
  local path="$1" msg="${2:-dir does not exist: $path}"
  TESTS_RUN=$((TESTS_RUN + 1))
  if [ -d "$path" ]; then
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo "  FAIL: $msg"
    return 1
  fi
  echo "  ok: $msg"
}

assert_contains() {
  local haystack="$1" needle="$2" msg="${3:-contains \"$needle\"}"
  TESTS_RUN=$((TESTS_RUN + 1))
  if [[ "$haystack" != *"$needle"* ]]; then
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo "  FAIL: $msg"
    return 1
  fi
  echo "  ok: $msg"
}

assert_not_contains() {
  local haystack="$1" needle="$2" msg="${3:-does not contain \"$needle\"}"
  TESTS_RUN=$((TESTS_RUN + 1))
  if [[ "$haystack" == *"$needle"* ]]; then
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo "  FAIL: $msg"
    return 1
  fi
  echo "  ok: $msg"
}

assert_file_contains() {
  local path="$1" needle="$2" msg="${3:-$path contains \"$needle\"}"
  TESTS_RUN=$((TESTS_RUN + 1))
  if [ ! -f "$path" ] || ! grep -qF -- "$needle" "$path"; then
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo "  FAIL: $msg"
    return 1
  fi
  echo "  ok: $msg"
}

assert_file_not_contains() {
  local path="$1" needle="$2" msg="${3:-$path does not contain \"$needle\"}"
  TESTS_RUN=$((TESTS_RUN + 1))
  if [ -f "$path" ] && grep -qF -- "$needle" "$path"; then
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo "  FAIL: $msg"
    return 1
  fi
  echo "  ok: $msg"
}
