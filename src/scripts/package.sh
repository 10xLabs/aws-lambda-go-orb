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

# Resolve the output to an absolute path before cd'ing into the input's parent.
# realpath is not used: BSD realpath requires the target file to exist and has
# no -m, so it cannot resolve a zip that has not been created yet.
OUTPUT_PARENT_DIR="$(dirname "$OUTPUT_FILE")"
mkdir -p "$OUTPUT_PARENT_DIR"
OUTPUT_REALPATH="$(cd "$OUTPUT_PARENT_DIR" && pwd)/$(basename "$OUTPUT_FILE")"

cd "$INPUT_PARENT_DIR" && zip "$OUTPUT_REALPATH" "$INPUT_FILE_PATH"

if [ -f "$OUTPUT_REALPATH" ]; then
    echo "Package created successfully: $OUTPUT_REALPATH"
    ls -lh "$OUTPUT_REALPATH"
else
    echo "Error: Failed to create package"
    exit 1
fi
