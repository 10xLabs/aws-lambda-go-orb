export GOPRIVATE="github.com/10xLabs"
go install github.com/10xLabs/gomarkdoc/cmd/gomarkdoc@latest
go env
# ls -al "$GOROOT/bin"
# ls -al "$GOPATH/bin"
# gomarkdoc

FILE_NAME=$(echo "$MODULE_NAME" | tr '[:upper:]' '[:lower:]')
mkdir docs
gomarkdoc "./$MODULE_PATH" -t func= > "docs/$FILE_NAME.md"

ls -al docs
