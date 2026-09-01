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

# Pulumi hashes the raw bytes of the zip, so the container's own metadata -- DOS
# timestamp, the UT/ux extra fields, the Unix mode -- becomes part of the resource
# identity and makes every build look like a code change. Pin all of it.
# TZ has to be set on zip too: Info-ZIP writes the DOS field via localtime().
cd "$INPUT_PARENT_DIR"
rm -f "$OUTPUT_REALPATH"
chmod 755 "$INPUT_FILE_PATH"
TZ=UTC touch -t 198001020000 "$INPUT_FILE_PATH"
TZ=UTC zip -X "$OUTPUT_REALPATH" "$INPUT_FILE_PATH"

if [ -f "$OUTPUT_REALPATH" ]; then
    echo "Package created successfully: $OUTPUT_REALPATH"
    ls -lh "$OUTPUT_REALPATH"
else
    echo "Error: Failed to create package"
    exit 1
fi
