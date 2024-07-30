#!/bin/bash
CURRENT_COVERAGE=$(GOEXPERIMENT='nocoverageredesign' GOFLAGS='-mod=vendor' go test -coverprofile=coverage.out -parallel $(nproc) ./... | awk '{ if ($1 ~ /coverage:/) { sum += $2; count++ }} END { print sum/count }')
CURRENT_COVERAGE=${CURRENT_COVERAGE%.*}
MINIMUM_COVERAGE=${MINIMUM_COVERAGE%.*}

echo "CURRENT: $CURRENT_COVERAGE - MINIMUM: $MINIMUM_COVERAGE"

if [ "$CURRENT_COVERAGE" -lt "$MINIMUM_COVERAGE" ]; then
    exit 1
fi
