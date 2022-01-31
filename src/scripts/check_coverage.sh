#!/bin/bash
sudo apt-get update > /dev/null
sudo apt-get install -y bc > /dev/null
CURRENT_COVERAGE=$(GOFLAGS='-mod=vendor' go tool cover -func cover.out | grep total | tail -n 1 |awk '{print substr($3, 1, length($3)-1)}')
echo "current: '$CURRENT_COVERAGE' - minimum: '$MINIMUM_COVERAGE'"
exit "$(echo "$CURRENT_COVERAGE < $MINIMUM_COVERAGE" | bc)"
