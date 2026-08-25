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

@test "package: fails when the input binary is missing" {
    INPUT_FILE=main OUTPUT_FILE=deploy/lambda.zip run bash "$SCRIPT"

    [ "$status" -eq 1 ]
    [[ "$output" == *"Input file main does not exist"* ]]
    [ ! -f deploy/lambda.zip ]
}
