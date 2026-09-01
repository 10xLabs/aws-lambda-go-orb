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
    # The script only sets GOTOOLCHAIN when go.mod asks for it; an inherited one
    # would make that assertion pass for the wrong reason.
    unset GOTOOLCHAIN
}

# stub_go <exit-code> — writes a fake `go` that logs its argv one-per-line to
# go-args and, on success, creates the file named after -o.
stub_go() {
    cat > "$WORKDIR/stub/go" <<STUB
#!/usr/bin/env bash
printf '%s\n' "\$@" > "$WORKDIR/go-args"
env | grep -E '^GO|^CGO_ENABLED=' | sort > "$WORKDIR/go-env"
if [ "$1" -ne 0 ]; then
    exit $1
fi
while [ "\$#" -gt 0 ]; do
    if [ "\$1" = "-o" ]; then
        echo "\$2" > "$WORKDIR/go-output"
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
    grep -Fxq -- "-mod=vendor" "$WORKDIR/go-args"
    grep -Fxq -- "-ldflags=-w -s" "$WORKDIR/go-args"
    [ "$(cat "$WORKDIR/go-output")" = "main" ]
    [ "$(tail -1 "$WORKDIR/go-args")" = "main.go" ]
    grep -Fxq "CGO_ENABLED=0" "$WORKDIR/go-env"
    grep -Fxq "GOOS=linux" "$WORKDIR/go-env"
    grep -Fxq "GOARCH=arm64" "$WORKDIR/go-env"
}

@test "build: passes -trimpath so the binary does not embed the checkout path" {
    stub_go 0

    INPUT_FILE=main.go OUTPUT_FILE=main ARCHITECTURE=arm64 run bash "$SCRIPT"

    [ "$status" -eq 0 ]
    grep -Fxq -- "-trimpath" "$WORKDIR/go-args"
}

@test "build: pins GOTOOLCHAIN to the go.mod toolchain directive" {
    stub_go 0
    printf 'module example.com/x\n\ngo 1.25.1\n\ntoolchain go1.26.7\n' > go.mod

    INPUT_FILE=main.go OUTPUT_FILE=main ARCHITECTURE=arm64 run bash "$SCRIPT"

    [ "$status" -eq 0 ]
    grep -Fxq "GOTOOLCHAIN=go1.26.7" "$WORKDIR/go-env"
}

@test "build: leaves GOTOOLCHAIN alone when go.mod declares no toolchain" {
    stub_go 0
    printf 'module example.com/x\n\ngo 1.25.1\n' > go.mod

    INPUT_FILE=main.go OUTPUT_FILE=main ARCHITECTURE=arm64 run bash "$SCRIPT"

    [ "$status" -eq 0 ]
    run grep -q "^GOTOOLCHAIN=" "$WORKDIR/go-env"
    [ "$status" -ne 0 ]
}

@test "build: honours a nested output path" {
    stub_go 0
    mkdir -p build

    INPUT_FILE=cmd/lambda/main.go OUTPUT_FILE=build/main ARCHITECTURE=amd64 run bash "$SCRIPT"

    [ "$status" -eq 0 ]
    [ -f build/main ]
    [ "$(cat "$WORKDIR/go-output")" = "build/main" ]
    [ "$(tail -1 "$WORKDIR/go-args")" = "cmd/lambda/main.go" ]
}

@test "build: fails when the compiler fails" {
    stub_go 2

    INPUT_FILE=main.go OUTPUT_FILE=main ARCHITECTURE=amd64 run bash "$SCRIPT"

    [ "$status" -ne 0 ]
    [ ! -f main ]
}
