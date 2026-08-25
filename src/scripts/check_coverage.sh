# shellcheck disable=SC2148

echo "=== Running coverage check ==="
echo "Minimum coverage required: ${MINIMUM_COVERAGE}%"

TEST_OUTPUT=$(GOFLAGS='-mod=vendor' go test -cover ./... 2>&1)
GO_TEST_EXIT_CODE=$?
echo "$TEST_OUTPUT"

# Without this the coverage of the packages that did pass is averaged and can
# clear the threshold while another package's tests were failing.
if [ "$GO_TEST_EXIT_CODE" -ne 0 ]; then
    echo "go test failed with exit code $GO_TEST_EXIT_CODE; not evaluating coverage"
    exit "$GO_TEST_EXIT_CODE"
fi

# Extract only lines with actual coverage percentages (not "no test files")
# Look for lines that contain "ok" and "coverage:" followed by a percentage
COVERAGE_VALUES=$(echo "$TEST_OUTPUT" | grep "ok" | grep "coverage:" | sed -n 's/.*coverage: \([0-9.]*\)%.*/\1/p')

if [ -z "$COVERAGE_VALUES" ]; then
    echo "No packages with test coverage found"
    exit 1
fi

CURRENT_COVERAGE=$(echo "$COVERAGE_VALUES" | awk '{ sum += $1; count++ } END { if (count > 0) printf "%.1f", sum/count; else print "0" }')

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
