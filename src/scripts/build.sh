# shellcheck disable=SC2148
set -e

echo "Building Lambda binary..."
echo "Architecture: $ARCHITECTURE"
echo "Input: $INPUT_FILE"
echo "Output: $OUTPUT_FILE"

# The go.mod toolchain directive is only a floor -- a newer ambient toolchain still
# wins and changes the binary. Promote it to an exact pin when one is declared.
GOTOOLCHAIN_PIN="$(awk '/^toolchain go1/ { print $2; exit }' go.mod 2>/dev/null || true)"
if [ -n "$GOTOOLCHAIN_PIN" ]; then
    echo "Toolchain: $GOTOOLCHAIN_PIN (pinned from go.mod)"
    export GOTOOLCHAIN="$GOTOOLCHAIN_PIN"
fi

# -trimpath: absolute source paths are otherwise embedded in the binary, which makes
# its bytes depend on where it was checked out.
CGO_ENABLED=0 GOOS=linux GOARCH=$ARCHITECTURE go build -v -mod=vendor -trimpath -ldflags="-w -s" -o "$OUTPUT_FILE" "$INPUT_FILE"

if [ -f "$OUTPUT_FILE" ]; then
    echo "Build successful: $OUTPUT_FILE created"
    ls -lh "$OUTPUT_FILE"
else
    echo "Build failed: $OUTPUT_FILE not created"
    exit 1
fi
