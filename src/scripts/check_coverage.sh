# shellcheck disable=SC2148
CURRENT_COVERAGE=$(GOFLAGS='-mod=vendor' go tool cover -func cover.out | grep total | tail -n 1 | awk '{print substr($3, 1, length($3)-1)}')
CURRENT_COVERAGE=${CURRENT_COVERAGE%.*}
MINIMUM_COVERAGE=${MINIMUM_COVERAGE%.*}

echo "CURRENT: $CURRENT_COVERAGE - MINIMUM: $MINIMUM_COVERAGE"

if [ "$CURRENT_COVERAGE" -lt "$MINIMUM_COVERAGE" ]; then
    exit 1
fi
