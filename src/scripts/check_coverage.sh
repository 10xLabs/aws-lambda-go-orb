sudo apt-get update
sudo apt-get install -y bc
CURRENT_COVERAGE=$(GOFLAGS='-mod=vendor' go tool cover -func cover.out | grep total | awk '{print substr($3, 1, length($3)-1)}')
exit "$(echo "$CURRENT_COVERAGE < $MINIMUM_COVERAGE" | bc)"
