# shellcheck disable=SC2148
set -e

echo "Building Lambda binary..."
echo "Architecture: $ARCHITECTURE"
echo "Input: $INPUT_FILE"
echo "Output: $OUTPUT_FILE"

CGO_ENABLED=0 GOOS=linux GOARCH=$ARCHITECTURE go build -v -mod=vendor -ldflags="-w -s" -o "$OUTPUT_FILE" "$INPUT_FILE"

if [ -f "$OUTPUT_FILE" ]; then
    echo "Build successful: $OUTPUT_FILE created"
    ls -lh "$OUTPUT_FILE"
else
    echo "Build failed: $OUTPUT_FILE not created"
    exit 1
fi
