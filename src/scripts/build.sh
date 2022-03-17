# shellcheck disable=SC2148
CGO_ENABLED=0 GOOS=linux GOARCH=$ARCHITECTURE go build -v -mod=vendor -ldflags="-w -s" -o "$OUTPUT_FILE" "$INPUT_FILE"
