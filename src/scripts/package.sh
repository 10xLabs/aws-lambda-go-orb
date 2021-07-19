apt-get update
apt-get install -y zip

# shellcheck disable=SC2153
INPUT_PARENT_DIR="$(dirname "$INPUT_FILE")"
INPUT_FILE_PATH="$(basename "$INPUT_FILE")"
OUTPUT_REALPATH="$(realpath "$OUTPUT_FILE")"
cd "$INPUT_PARENT_DIR" && zip "$OUTPUT_REALPATH" "$INPUT_FILE_PATH"
