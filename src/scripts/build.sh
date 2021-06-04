CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build "$INPUT_FILE" -v -ldflags="-w -s" -o "$OUTPUT_FILE"
