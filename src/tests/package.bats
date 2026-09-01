#!/usr/bin/env bats

# Tests for src/scripts/package.sh
#
# The script is included verbatim into a CircleCI `run` step, so it has no
# shebang and no functions: it is exercised here by executing it with the same
# environment variables src/commands/build.yml binds.

setup() {
    SCRIPT="$BATS_TEST_DIRNAME/../scripts/package.sh"
    WORKDIR="$BATS_TEST_TMPDIR/$BATS_TEST_NAME"
    mkdir -p "$WORKDIR"
    cd "$WORKDIR" || exit 1
}

@test "package: creates the zip when the output directory does not exist" {
    # Regression: realpath fails on a missing parent directory, so the output
    # directory has to be created before the realpath call. Consumer repos are
    # not required to commit deploy/.
    echo "binary" > main
    [ ! -d deploy ]

    INPUT_FILE=main OUTPUT_FILE=deploy/lambda.zip run bash "$SCRIPT"

    [ "$status" -eq 0 ]
    [ -f deploy/lambda.zip ]
}

@test "package: zips the binary at the root of the archive, not its path" {
    mkdir -p build/bin
    echo "binary" > build/bin/main

    INPUT_FILE=build/bin/main OUTPUT_FILE=deploy/lambda.zip run bash "$SCRIPT"

    [ "$status" -eq 0 ]
    # zip -sf lists the archive contents; unzip is not guaranteed on the executor
    zip -sf deploy/lambda.zip | grep -Eq '^[[:space:]]+main$'
    ! zip -sf deploy/lambda.zip | grep -Fq "build/bin"
}

@test "package: reuses an existing output directory" {
    echo "binary" > main
    mkdir -p deploy

    INPUT_FILE=main OUTPUT_FILE=deploy/lambda.zip run bash "$SCRIPT"

    [ "$status" -eq 0 ]
    [ -f deploy/lambda.zip ]
}

@test "package: produces byte-identical archives across runs" {
    # Pulumi hashes the raw zip bytes, so anything the container records about
    # the build -- clock, umask, uid -- shows up as a spurious code change.
    # The rebuild is simulated by re-stamping identical content, which is what
    # `go build` does to the binary on every run.
    echo "binary" > main
    touch -t 202601011234 main
    chmod 700 main

    INPUT_FILE=main OUTPUT_FILE=deploy/lambda.zip run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    first="$(shasum -a 256 < deploy/lambda.zip)"

    echo "binary" > main
    touch -t 202608302345 main
    chmod 744 main

    INPUT_FILE=main OUTPUT_FILE=deploy/lambda.zip run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    second="$(shasum -a 256 < deploy/lambda.zip)"

    [ "$first" = "$second" ]
}

@test "package: pins the timestamp, mode and extra fields in the archive" {
    echo "binary" > main
    touch -t 202601011234 main
    chmod 700 main

    INPUT_FILE=main OUTPUT_FILE=deploy/lambda.zip run bash "$SCRIPT"

    [ "$status" -eq 0 ]
    zipinfo -v deploy/lambda.zip | grep -Fq "1980 Jan 2 00:00:00"
    zipinfo -v deploy/lambda.zip | grep -Fq "length of extra field:                          0 bytes"
    zipinfo -v deploy/lambda.zip | grep -Fq "(100755 octal)"
}

@test "package: replaces an existing archive rather than updating it" {
    # zip updates in place, so a stale entry would survive and keep its bytes.
    mkdir -p deploy
    echo "stale" > leftover
    zip -q deploy/lambda.zip leftover
    echo "binary" > main

    INPUT_FILE=main OUTPUT_FILE=deploy/lambda.zip run bash "$SCRIPT"

    [ "$status" -eq 0 ]
    run zip -sf deploy/lambda.zip
    [[ "$output" != *leftover* ]]
}

@test "package: fails when the input binary is missing" {
    INPUT_FILE=main OUTPUT_FILE=deploy/lambda.zip run bash "$SCRIPT"

    [ "$status" -eq 1 ]
    [[ "$output" == *"Input file main does not exist"* ]]
    [ ! -f deploy/lambda.zip ]
}
