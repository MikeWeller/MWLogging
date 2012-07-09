#!/bin/bash

# A dirty bash script to test that our compile-time log levels work
# correctly

set -e
set -u
set -o pipefail

SRCROOT=$(dirname "$0")
CC=$(xcrun -find clang)

test_compile_time_level_output_count() {
    log_level="$1"
    expected_line_count="$2"
    search_string="$3"
    expected_search_string_count="$4"

    if [[ "$log_level" == "ASL_LEVEL_EMERGENCY" ]]; then
        emergency_enabled="1"
    else
        emergency_enabled="0"
    fi

    echo -n "Testing $log_level compile-time level works..."

    binary_name="$TMPDIR/MWLogging_tests.out"

    "$CC" "$SRCROOT/test.m" "$SRCROOT/MWLogging.m" \
        -o "$binary_name" \
        -framework Foundation \
        "-DMW_COMPILE_TIME_LOG_LEVEL=$log_level" \
        "-DEMERGENCY_ENABLED=$emergency_enabled"

    output=$("$binary_name" 2>&1)
    actual_line_count=$(echo "$output" | wc -l)

    if (( "$actual_line_count" != "$expected_line_count" )); then
        echo "[FAILED]"
        echo "Failed test for $log_level, expected $expected_line_count lines with log level $log_level but got $actual_line_count" >&2
        exit 1
    fi

    # silly grep and its non-zero return value... we || true to work around
    actual_search_string_count=$(echo "$output" | grep "$search_string" | wc -l || true)

    if (( "$actual_search_string_count" != "$expected_search_string_count" )); then
        echo "[FAILED]"
        echo "Failed test for $log_level, expected $search_string $expected_search_string_count times but got $actual_search_string_count" >&2
        exit 1
    fi

    echo "[PASSED]"
}

test_compile_time_level_output_count "ASL_LEVEL_EMERGENCY" 1 "<Emergency>" "1"
test_compile_time_level_output_count "ASL_LEVEL_ALERT" 1 "<Alert>" "1"
test_compile_time_level_output_count "ASL_LEVEL_CRIT" 2 "<Critical>" "1"
test_compile_time_level_output_count "ASL_LEVEL_ERR" 3 "<Error>" "1"
test_compile_time_level_output_count "ASL_LEVEL_WARNING" 4 "<Warning>" "1"
test_compile_time_level_output_count "ASL_LEVEL_NOTICE" 5 "<Notice>" "1"
test_compile_time_level_output_count "ASL_LEVEL_INFO" 6 "<Info>" "1"
test_compile_time_level_output_count "ASL_LEVEL_DEBUG" 7 "<Debug>" "1"

echo "All tests passed"
