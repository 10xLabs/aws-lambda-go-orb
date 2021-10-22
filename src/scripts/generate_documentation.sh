export GOPRIVATE="github.com/10xLabs"
go install github.com/10xLabs/gomarkdoc/cmd/gomarkdoc@latest
go env
ls -al "$GOROOT/bin"
ls -al "$GOPATH/bin"
gomarkdoc
