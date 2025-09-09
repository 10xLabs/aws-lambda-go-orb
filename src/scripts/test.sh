# shellcheck disable=SC2148

echo "=== Starting test execution ==="
echo "RESULTS_FOLDER: $RESULTS_FOLDER"
echo "Current directory: $(pwd)"
echo "Go version: $(go version)"

mkdir -p "$RESULTS_FOLDER"
echo "Created results folder: $RESULTS_FOLDER"

echo "=== Running tests with coverage ==="
GOFLAGS='-mod=vendor' gotestsum --junitfile "$RESULTS_FOLDER/unit-tests.xml" -- -coverprofile=cover.out -v ./...
TEST_EXIT_CODE=$?

echo "=== Test execution completed ==="
echo "Test exit code: $TEST_EXIT_CODE"

if [ -f "cover.out" ]; then
    echo "Coverage file created successfully"
    echo "Coverage file size: $(wc -l < cover.out) lines"
else
    echo "WARNING: Coverage file 'cover.out' was not created"
fi

echo "Contents of current directory:"
ls -la

exit $TEST_EXIT_CODE
