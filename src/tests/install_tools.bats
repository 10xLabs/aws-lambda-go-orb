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

@test "pulumi: puts the update-check skip on the PATH export for later steps" {
    fake_tool "$HOME/.pulumi/bin/pulumi" "v3.259.0"

    PULUMI_VERSION=3.259.0 run bash "$SCRIPTS/install_pulumi_cli.sh"

    [ "$status" -eq 0 ]
    grep -Fxq "export PULUMI_SKIP_UPDATE_CHECK=true" "$BASH_ENV"
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

# fake_package <name> <version> — a node_modules entry with a version field.
fake_package() {
    mkdir -p "node_modules/$1"
    printf '{"name":"%s","version":"%s"}\n' "$1" "$2" > "node_modules/$1/package.json"
}

@test "commitlint: reuses the cached install when both packages match the version" {
    fake_package "@commitlint/cli" "21.2.2"
    fake_package "@commitlint/config-conventional" "21.2.2"
    fake_tool "$WORKDIR/stub/npx" "21.2.2"

    COMMITLINT_VERSION=21.2.2 run bash "$SCRIPTS/install_commitlint.sh"

    [ "$status" -eq 0 ]
    [[ "$output" == *"restored from cache"* ]]
    [ ! -f "$WORKDIR/network-calls" ]
}

@test "commitlint: reinstalls when the cached cli is a different version" {
    fake_package "@commitlint/cli" "20.1.0"
    fake_package "@commitlint/config-conventional" "21.2.2"
    fake_tool "$WORKDIR/stub/npx" "21.2.2"

    COMMITLINT_VERSION=21.2.2 run bash "$SCRIPTS/install_commitlint.sh"

    [[ "$output" == *"Installing commitlint 21.2.2"* ]]
    grep -Fq "@commitlint/cli@21.2.2" "$WORKDIR/network-calls"
}

@test "commitlint: reinstalls when only the cli is cached and the config is missing" {
    fake_package "@commitlint/cli" "21.2.2"
    fake_tool "$WORKDIR/stub/npx" "21.2.2"

    COMMITLINT_VERSION=21.2.2 run bash "$SCRIPTS/install_commitlint.sh"

    grep -Fq "@commitlint/config-conventional@21.2.2" "$WORKDIR/network-calls"
}

@test "commitlint: installs both the cli and the conventional config when absent" {
    fake_tool "$WORKDIR/stub/npx" "21.2.2"

    COMMITLINT_VERSION=21.2.2 run bash "$SCRIPTS/install_commitlint.sh"

    grep -Fq "@commitlint/cli@21.2.2" "$WORKDIR/network-calls"
    grep -Fq "@commitlint/config-conventional@21.2.2" "$WORKDIR/network-calls"
}

# Tests for check_coverage.sh, whose gate must not be reachable when the test
# run itself failed. "go" is stubbed to control the exit code and the output the
# script parses.
@test "coverage: fails when go test fails, even if a package reported coverage" {
    cat > "$WORKDIR/stub/go" <<'STUB'
#!/usr/bin/env bash
echo "ok  	m/pass	0.002s	coverage: 100.0% of statements"
echo "FAIL	m/fail	0.003s"
exit 1
STUB
    chmod +x "$WORKDIR/stub/go"

    MINIMUM_COVERAGE=50.00 run bash "$SCRIPTS/check_coverage.sh"

    [ "$status" -ne 0 ]
    [[ "$output" == *"go test failed"* ]]
    [[ "$output" != *"Coverage check passed"* ]]
}

@test "coverage: passes when go test succeeds and coverage clears the minimum" {
    cat > "$WORKDIR/stub/go" <<'STUB'
#!/usr/bin/env bash
echo "ok  	m/pass	0.002s	coverage: 90.0% of statements"
STUB
    chmod +x "$WORKDIR/stub/go"

    MINIMUM_COVERAGE=50.00 run bash "$SCRIPTS/check_coverage.sh"

    [ "$status" -eq 0 ]
    [[ "$output" == *"Coverage check passed"* ]]
}

@test "coverage: fails when coverage is below the minimum" {
    cat > "$WORKDIR/stub/go" <<'STUB'
#!/usr/bin/env bash
echo "ok  	m/pass	0.002s	coverage: 10.0% of statements"
STUB
    chmod +x "$WORKDIR/stub/go"

    MINIMUM_COVERAGE=50.00 run bash "$SCRIPTS/check_coverage.sh"

    [ "$status" -ne 0 ]
}

@test "coverage: ignores a package path that merely contains \"ok\"" {
    # Regression: an unanchored grep "ok" matched the 0.0% line of
    # internal/pkg/invoker, which has no test files, and dragged the average
    # from 87.5% to 58.3% (currencies-handler build 4416). "go test -cover"
    # reports a package with no test files as a tab-indented line carrying
    # neither an "ok" nor a "?" prefix, so only anchoring the match to a real
    # result line keeps it out of the average.
    cat > "$WORKDIR/stub/go" <<'STUB'
#!/usr/bin/env bash
echo "ok  	github.com/10xLabs/currencies-handler/internal/api/admin/graphql/resolver	0.027s	coverage: 85.2% of statements"
echo "ok  	github.com/10xLabs/currencies-handler/internal/handler	0.027s	coverage: 89.8% of statements"
printf '\t%s\t\tcoverage: 0.0%% of statements\n' "github.com/10xLabs/currencies-handler/internal/pkg/invoker"
STUB
    chmod +x "$WORKDIR/stub/go"

    MINIMUM_COVERAGE=85.00 run bash "$SCRIPTS/check_coverage.sh"

    [ "$status" -eq 0 ]
    [[ "$output" == *"Average coverage: 87.5%"* ]]
    [[ "$output" != *"58.3%"* ]]
}
