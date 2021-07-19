mkdir -p "$RESULTS_FOLDER"
curl -sSL "https://github.com/gotestyourself/gotestsum/releases/download/v1.6.4/gotestsum_1.6.4_linux_amd64.tar.gz"
tar -xz -C /usr/local/bin gotestsum
GOFLAGS='-mod=vendor' gotestsum --junitfile "$RESULTS_FOLDER/unit-tests.xml" -- -coverprofile=cover.out -v ./...
