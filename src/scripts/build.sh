# shellcheck disable=SC2148
set -e

echo "Building Lambda binary..."
echo "Architecture: $ARCHITECTURE"
echo "Input: $INPUT_FILE"
echo "Output: $OUTPUT_FILE"

# The go.mod toolchain directive is only a floor -- a newer installed toolchain still
# wins and changes the binary -- so promote it to an exact pin. Many repos carry a stale
# directive, and pinning to that would build production code with an end-of-life
# compiler, so only honour it when it is at least as new as what Go picks by itself.
GOTOOLCHAIN_PIN="$(awk '/^[[:space:]]*toolchain go1/ { print $2; exit }' go.mod 2>/dev/null || true)"
if [ -n "$GOTOOLCHAIN_PIN" ]; then
    GO_DEFAULT="$(go env GOVERSION)"
    NEWEST="go$(printf '%s\n%s\n' "${GOTOOLCHAIN_PIN#go}" "${GO_DEFAULT#go}" | sort -V | tail -1)"
    if [ "$NEWEST" = "$GOTOOLCHAIN_PIN" ]; then
        echo "Toolchain: $GOTOOLCHAIN_PIN (pinned from go.mod)"
        export GOTOOLCHAIN="$GOTOOLCHAIN_PIN"
    else
        echo "Toolchain: go.mod asks for $GOTOOLCHAIN_PIN, older than $GO_DEFAULT."
        echo "Building with $GO_DEFAULT; bump the toolchain directive to pin it."
    fi
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
