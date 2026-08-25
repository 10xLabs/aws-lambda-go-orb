# shellcheck disable=SC2148

echo "=== Running coverage check ==="
echo "Minimum coverage required: ${MINIMUM_COVERAGE}%"

# Run tests with coverage and capture output
TEST_OUTPUT=$(GOFLAGS='-mod=vendor' go test -cover ./... 2>&1)
echo "$TEST_OUTPUT"

# Extract only lines with actual coverage percentages (not "no test files")
# Look for lines that contain "ok" and "coverage:" followed by a percentage
COVERAGE_VALUES=$(echo "$TEST_OUTPUT" | grep "ok" | grep "coverage:" | sed -n 's/.*coverage: \([0-9.]*\)%.*/\1/p')

if [ -z "$COVERAGE_VALUES" ]; then
    echo "No packages with test coverage found"
    exit 1
fi

# Calculate average coverage
CURRENT_COVERAGE=$(echo "$COVERAGE_VALUES" | awk '{ sum += $1; count++ } END { if (count > 0) printf "%.1f", sum/count; else print "0" }')

# Convert to integers for comparison
CURRENT_INT=${CURRENT_COVERAGE%.*}
MINIMUM_INT=${MINIMUM_COVERAGE%.*}

echo ""
echo "Packages with tests:"
echo "$TEST_OUTPUT" | grep "ok" | grep "coverage:"
echo ""
echo "Average coverage: ${CURRENT_COVERAGE}%"
echo "Minimum required: ${MINIMUM_COVERAGE}%"

if [ "$CURRENT_INT" -lt "$MINIMUM_INT" ]; then
    echo "Coverage ${CURRENT_COVERAGE}% is below minimum ${MINIMUM_COVERAGE}%"
    exit 1
fi

echo "Coverage check passed!"
