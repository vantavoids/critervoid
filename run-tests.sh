#!/bin/bash

set -e

TESTS_DIR="${TESTS_DIR:-tests}"
BUILD_DIR="${BUILD_DIR:-/tmp/test-build}"
COMPILER="${COMPILER:-cc}"
CRITERION_FLAGS="${CRITERION_FLAGS:--lcriterion}"
VERBOSE="${VERBOSE:-0}"

if [ ! -d "$TESTS_DIR" ]; then
    echo "Error: Tests directory '$TESTS_DIR' not found"
    echo "Make sure you mounted your project directory to /workspace"
    exit 1
fi

TEST_FILES=$(find "$TESTS_DIR" -name "*.c" -type f)

if [ -z "$TEST_FILES" ]; then
    echo "Error: No test files (*.c) found in $TESTS_DIR"
    exit 1
fi

echo "=== Found test files ==="
echo "$TEST_FILES"
echo ""

mkdir -p "$BUILD_DIR"

echo "=== Compiling tests ==="
TEST_EXECUTABLE="$BUILD_DIR/test_runner"

if [ -n "$EXTRA_FLAGS" ]; then
    COMPILE_CMD="$COMPILER $TEST_FILES -o $TEST_EXECUTABLE $CRITERION_FLAGS $EXTRA_FLAGS"
else
    COMPILE_CMD="$COMPILER $TEST_FILES -o $TEST_EXECUTABLE $CRITERION_FLAGS"
fi

echo "Compile command: $COMPILE_CMD"
eval "$COMPILE_CMD"

if [ $? -ne 0 ]; then
    echo "Error: Compilation failed"
    exit 1
fi

echo ""
echo "=== Running tests ==="

if [ "$VERBOSE" = "1" ]; then
    "$TEST_EXECUTABLE" --verbose
else
    "$TEST_EXECUTABLE"
fi

EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo ""
    echo "=== All tests passed! ==="
else
    echo ""
    echo "=== Tests failed with exit code $EXIT_CODE ==="
fi

exit $EXIT_CODE
