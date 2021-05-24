mkdir -p "$ARTIFACTS_FOLDER"
go tool cover -html=cover.out -o "$ARTIFACTS_FOLDER/coverage.html"
