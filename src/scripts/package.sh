# shellcheck disable=SC2148
# shellcheck disable=SC2153
set -e

echo "Packaging Lambda function..."
echo "Input: $INPUT_FILE"
echo "Output: $OUTPUT_FILE"

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file $INPUT_FILE does not exist"
    exit 1
fi

INPUT_PARENT_DIR="$(dirname "$INPUT_FILE")"
INPUT_FILE_PATH="$(basename "$INPUT_FILE")"

# Create output directory before resolving its realpath
mkdir -p "$(dirname "$OUTPUT_FILE")"
OUTPUT_REALPATH="$(realpath "$OUTPUT_FILE")"

cd "$INPUT_PARENT_DIR" && zip "$OUTPUT_REALPATH" "$INPUT_FILE_PATH"

if [ -f "$OUTPUT_REALPATH" ]; then
    echo "Package created successfully: $OUTPUT_REALPATH"
    ls -lh "$OUTPUT_REALPATH"
else
    echo "Error: Failed to create package"
    exit 1
fi
