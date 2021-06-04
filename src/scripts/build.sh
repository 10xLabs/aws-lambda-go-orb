CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -v -ldflags="-w -s" -o "$OUTPUT_FILE" "$INPUT_FILE"
