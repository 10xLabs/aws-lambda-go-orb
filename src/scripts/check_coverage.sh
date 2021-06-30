sudo apt-get update
sudo apt-get install -y bc
CURRENT_COVERAGE=$(GOFLAGS='-mod=vendor' go tool cover -func cover.out | grep total | awk '{print substr($3, 1, length($3)-1)}')
echo "current '$CURRENT_COVERAGE' minimum '$MINIMUM_COVERAGE'"
if [$CURRENT_COVERAGE == "100.0"] then
  exit 0
fi
exit "$(echo "$CURRENT_COVERAGE < $MINIMUM_COVERAGE" | bc)"
