export GOPRIVATE="github.com/10xLabs"
go install github.com/10xLabs/gomarkdoc/cmd/gomarkdoc@latest

mkdir docs
FILE_NAME=$(echo "$MODULE_NAME" | tr '[:upper:]' '[:lower:]')
gomarkdoc "./$MODULE_PATH" -t func= > "docs/$FILE_NAME.md"

echo "export DOCUMENTATION_FILE=docs/$FILE_NAME.md" >> "$BASH_ENV"
