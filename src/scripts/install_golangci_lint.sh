#! /bin/bash
cd "$WORKING_DIRECTORY" || exit

curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s v1.58.0
