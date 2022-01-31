# shellcheck disable=SC2148
export GOPRIVATE="github.com/10xLabs"
go install github.com/10xLabs/gomarkdoc/cmd/gomarkdoc@latest

mkdir -p /tmp/docs
FILE_NAME=$(echo "$MODULE_NAME" | tr '[:upper:]' '[:lower:]')
gomarkdoc "./$MODULE_PATH" -t func= > "/tmp/docs/$FILE_NAME.md"

echo "export DOCUMENTATION_FILE=/tmp/docs/$FILE_NAME.md" >> "$BASH_ENV"
