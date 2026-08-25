#!/usr/bin/env bats

# Tests for the tool install scripts used by the executors that do not ship
# these tools. Network commands (curl, npm, tar) are stubbed on PATH, so the
# cache-hit branch is asserted to make no download at all.

setup() {
    SCRIPTS="$BATS_TEST_DIRNAME/../scripts"
    WORKDIR="$BATS_TEST_TMPDIR/$BATS_TEST_NAME"
    mkdir -p "$WORKDIR/stub" "$WORKDIR/home"
    cd "$WORKDIR" || exit 1
    PATH="$WORKDIR/stub:$PATH"
    HOME="$WORKDIR/home"
    BASH_ENV="$WORKDIR/bash_env"
    : > "$BASH_ENV"
    export HOME BASH_ENV
    # Any network call records itself and fails the assertion below.
    for cmd in curl npm tar; do
        printf '#!/usr/bin/env bash\necho "%s $*" >> "%s/network-calls"\n' "$cmd" "$WORKDIR" \
            > "$WORKDIR/stub/$cmd"
        chmod +x "$WORKDIR/stub/$cmd"
    done
}

# fake_tool <path> <output> — a stub binary printing a fixed version string.
fake_tool() {
    mkdir -p "$(dirname "$1")"
    printf '#!/usr/bin/env bash\necho "%s"\n' "$2" > "$1"
    chmod +x "$1"
}

@test "pulumi: reuses the cached CLI when the version already matches" {
    fake_tool "$HOME/.pulumi/bin/pulumi" "v3.259.0"

    PULUMI_VERSION=3.259.0 run bash "$SCRIPTS/install_pulumi_cli.sh"

    [ "$status" -eq 0 ]
    [[ "$output" == *"restored from cache"* ]]
    [ ! -f "$WORKDIR/network-calls" ]
    grep -Fq ".pulumi/bin" "$BASH_ENV"
}

@test "pulumi: downloads when the cached CLI is a different version" {
    fake_tool "$HOME/.pulumi/bin/pulumi" "v3.100.0"

    PULUMI_VERSION=3.259.0 run bash "$SCRIPTS/install_pulumi_cli.sh"

    [[ "$output" == *"Installing Pulumi v3.259.0"* ]]
    grep -Fq "get.pulumi.com" "$WORKDIR/network-calls"
}

@test "pulumi: downloads when nothing is cached" {
    PULUMI_VERSION=3.259.0 run bash "$SCRIPTS/install_pulumi_cli.sh"

    grep -Fq "get.pulumi.com" "$WORKDIR/network-calls"
}

@test "github cli: reuses the cached binary when the version already matches" {
    fake_tool "$HOME/.local/bin/gh" "gh version 2.98.0 (2026-08-20)"

    GH_VERSION=2.98.0 run bash "$SCRIPTS/install_github_cli.sh"

    [ "$status" -eq 0 ]
    [[ "$output" == *"restored from cache"* ]]
    [ ! -f "$WORKDIR/network-calls" ]
    grep -Fq ".local/bin" "$BASH_ENV"
}

@test "github cli: downloads when the cached binary is a different version" {
    fake_tool "$HOME/.local/bin/gh" "gh version 2.50.0 (2024-01-01)"

    GH_VERSION=2.98.0 run bash "$SCRIPTS/install_github_cli.sh"

    grep -Fq "github.com/cli/cli/releases" "$WORKDIR/network-calls"
}

@test "github cli: requests an asset matching the machine architecture" {
    GH_VERSION=2.98.0 run bash "$SCRIPTS/install_github_cli.sh"

    case "$(uname -m)" in
        aarch64 | arm64) grep -Fq "linux_arm64" "$WORKDIR/network-calls" ;;
        x86_64) grep -Fq "linux_amd64" "$WORKDIR/network-calls" ;;
    esac
}

@test "commitlint: reuses the cached install when node_modules is present" {
    fake_tool "node_modules/.bin/commitlint" "21.2.2"
    fake_tool "$WORKDIR/stub/npx" "21.2.2"

    COMMITLINT_VERSION=21.2.2 run bash "$SCRIPTS/install_commitlint.sh"

    [ "$status" -eq 0 ]
    [[ "$output" == *"restored from cache"* ]]
    [ ! -f "$WORKDIR/network-calls" ]
}

@test "commitlint: installs both the cli and the conventional config when absent" {
    fake_tool "$WORKDIR/stub/npx" "21.2.2"

    COMMITLINT_VERSION=21.2.2 run bash "$SCRIPTS/install_commitlint.sh"

    grep -Fq "@commitlint/cli@21.2.2" "$WORKDIR/network-calls"
    grep -Fq "@commitlint/config-conventional@21.2.2" "$WORKDIR/network-calls"
}
