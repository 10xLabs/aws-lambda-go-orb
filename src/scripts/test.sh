# shellcheck disable=SC2148

echo "=== Starting test execution ==="
echo "RESULTS_FOLDER: $RESULTS_FOLDER"
echo "Current directory: $(pwd)"
echo "Go version: $(go version)"

mkdir -p "$RESULTS_FOLDER"
echo "Created results folder: $RESULTS_FOLDER"

echo "=== Running tests with coverage ==="

# First, run tests with coverage profile generation
echo "Running go test with coverage..."
GOFLAGS='-mod=vendor' go test -coverprofile=cover.out -v ./...
GO_TEST_EXIT_CODE=$?
echo "Go test exit code: $GO_TEST_EXIT_CODE"

# Then run gotestsum for JUnit output (if go test succeeded)
if [ $GO_TEST_EXIT_CODE -eq 0 ]; then
    echo "Running gotestsum for JUnit output..."
    GOFLAGS='-mod=vendor' gotestsum --junitfile "$RESULTS_FOLDER/unit-tests.xml" -- -v ./...
    GOTESTSUM_EXIT_CODE=$?
    echo "Gotestsum exit code: $GOTESTSUM_EXIT_CODE"
    # Use go test exit code as the authoritative result
    TEST_EXIT_CODE=$GO_TEST_EXIT_CODE
else
    echo "Go test failed, skipping gotestsum..."
    TEST_EXIT_CODE=$GO_TEST_EXIT_CODE
fi

echo "=== Test execution completed ==="
echo "Final test exit code: $TEST_EXIT_CODE"

if [ -f "cover.out" ]; then
    echo "Coverage file created successfully"
    echo "Coverage file size: $(wc -l < cover.out) lines"
else
    echo "WARNING: Coverage file 'cover.out' was not created"
fi

exit $TEST_EXIT_CODE
