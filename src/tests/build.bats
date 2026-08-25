#!/usr/bin/env bats

# Tests for src/scripts/build.sh
#
# `go` is stubbed on PATH so the test does not need a Go toolchain or a real
# module: the stub records the arguments it was called with and creates the
# requested output file.

setup() {
    SCRIPT="$BATS_TEST_DIRNAME/../scripts/build.sh"
    WORKDIR="$BATS_TEST_TMPDIR/$BATS_TEST_NAME"
    mkdir -p "$WORKDIR/stub"
    cd "$WORKDIR" || exit 1
    PATH="$WORKDIR/stub:$PATH"
}

# stub_go <exit-code> — writes a fake `go` that logs its argv to go-args and,
# on success, creates the file named after -o.
stub_go() {
    cat > "$WORKDIR/stub/go" <<STUB
#!/usr/bin/env bash
echo "\$@" > "$WORKDIR/go-args"
env | grep -E '^(CGO_ENABLED|GOOS|GOARCH)=' | sort > "$WORKDIR/go-env"
if [ "$1" -ne 0 ]; then
    exit $1
fi
while [ "\$#" -gt 0 ]; do
    if [ "\$1" = "-o" ]; then
        echo "fake-binary" > "\$2"
        break
    fi
    shift
done
STUB
    chmod +x "$WORKDIR/stub/go"
}

@test "build: cross-compiles a static linux binary for the requested architecture" {
    stub_go 0

    INPUT_FILE=main.go OUTPUT_FILE=main ARCHITECTURE=arm64 run bash "$SCRIPT"

    [ "$status" -eq 0 ]
    [ -f main ]
    grep -Fq -- "-mod=vendor" "$WORKDIR/go-args"
    grep -Fq -- "-ldflags=-w -s" "$WORKDIR/go-args"
    grep -Fq -- "-o main main.go" "$WORKDIR/go-args"
    grep -Fxq "CGO_ENABLED=0" "$WORKDIR/go-env"
    grep -Fxq "GOOS=linux" "$WORKDIR/go-env"
    grep -Fxq "GOARCH=arm64" "$WORKDIR/go-env"
}

@test "build: honours a nested output path" {
    stub_go 0
    mkdir -p build

    INPUT_FILE=cmd/lambda/main.go OUTPUT_FILE=build/main ARCHITECTURE=amd64 run bash "$SCRIPT"

    [ "$status" -eq 0 ]
    [ -f build/main ]
    grep -Fq -- "-o build/main cmd/lambda/main.go" "$WORKDIR/go-args"
}

@test "build: fails when the compiler fails" {
    stub_go 2

    INPUT_FILE=main.go OUTPUT_FILE=main ARCHITECTURE=amd64 run bash "$SCRIPT"

    [ "$status" -ne 0 ]
    [ ! -f main ]
}
