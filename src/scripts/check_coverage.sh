sudo apt-get update
sudo apt-get install -y bc
CURRENT_COVERAGE=$(GOFLAGS='-mod=vendor' go tool cover -func cover.out | grep total | awk '{print substr($3, 1, length($3)-1)}')
echo $CURRENT_COVERAGE
echo $MINIMUM_COVERAGE
exit "$(echo "$CURRENT_COVERAGE < $MINIMUM_COVERAGE" | bc)"
