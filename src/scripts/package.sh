# shellcheck disable=SC2153
input_parentdir="$(dirname "$INPUT_FILE")"
input_file="$(basename "$INPUT_FILE")"
output_realpath="$(realpath "$OUTPUT_FILE")"
cd "$input_parentdir" && zip "$output_realpath" "$input_file"
