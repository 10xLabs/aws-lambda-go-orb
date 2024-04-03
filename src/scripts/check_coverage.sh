# shellcheck disable=SC2148

# we may use this again when go version 1.22 toolchain gets fixed
#CURRENT_COVERAGE=$(GOEXPERIMENT='nocoverageredesign' GOFLAGS='-mod=vendor' go tool cover -func cover.out | grep total | tail -n 1 | awk '{print substr($3, 1, length($3)-1)}')

CURRENT_COVERAGE=$(GOEXPERIMENT='nocoverageredesign' GOFLAGS='-mod=vendor' go test --cover ./... | grep -Eo '[0-9]+\.[0-9]+% of statements' | awk -F'%' '{print $1}' | awk '{ sum += $1 } END { print sum/NR }')
CURRENT_COVERAGE=${CURRENT_COVERAGE%.*}
MINIMUM_COVERAGE=${MINIMUM_COVERAGE%.*}

echo "CURRENT: $CURRENT_COVERAGE - MINIMUM: $MINIMUM_COVERAGE"

if [ "$CURRENT_COVERAGE" -lt "$MINIMUM_COVERAGE" ]; then
    exit 1
fi
