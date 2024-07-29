#! /bin/bash
cd "$WORKING_DIRECTORY" || exit
sudo npm install -g @commitlint/cli @commitlint/config-conventional
curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s v1.58.0
