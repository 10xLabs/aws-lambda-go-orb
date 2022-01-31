mkdir -p "$ARTIFACTS_FOLDER"
GOFLAGS='-mod=vendor' go tool cover -html=cover.out -o "$ARTIFACTS_FOLDER/coverage.html"
