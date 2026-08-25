#!/usr/bin/env bats

# Tests for src/scripts/install_pulumi_deps.sh
#
# `npm` and `yarn` are stubbed on PATH so no network access or real package
# manifest is needed; the stubs only record that they ran.

setup() {
    SCRIPT="$BATS_TEST_DIRNAME/../scripts/install_pulumi_deps.sh"
    WORKDIR="$BATS_TEST_TMPDIR/$BATS_TEST_NAME"
    mkdir -p "$WORKDIR/stub" "$WORKDIR/deploy"
    cd "$WORKDIR" || exit 1
    PATH="$WORKDIR/stub:$PATH"

    for pm in npm yarn; do
        printf '#!/usr/bin/env bash\necho "%s $*" >> "%s/pm-calls"\n' "$pm" "$WORKDIR" \
            > "$WORKDIR/stub/$pm"
        chmod +x "$WORKDIR/stub/$pm"
    done
}

@test "install_pulumi_deps: fails when GITHUB_PAT is not set" {
    WORKING_DIRECTORY="$WORKDIR/deploy" run bash "$SCRIPT"

    [ "$status" -eq 1 ]
    [[ "$output" == *"GITHUB_PAT environment variable is not set"* ]]
    [ ! -f "$WORKDIR/deploy/.npmrc" ]
}

@test "install_pulumi_deps: fails when GITHUB_PAT is empty" {
    WORKING_DIRECTORY="$WORKDIR/deploy" GITHUB_PAT="" run bash "$SCRIPT"

    [ "$status" -eq 1 ]
    [ ! -f "$WORKDIR/deploy/.npmrc" ]
}

@test "install_pulumi_deps: writes the npm auth token into the working directory" {
    WORKING_DIRECTORY="$WORKDIR/deploy" GITHUB_PAT=secret-pat \
        NPM_GITHUB_REGISTRY=https://npm.pkg.github.com run bash "$SCRIPT"

    [ "$status" -eq 0 ]
    grep -Fxq "//npm.pkg.github.com/:_authToken=secret-pat" "$WORKDIR/deploy/.npmrc"
    grep -Fxq "@10xLabs:registry=https://npm.pkg.github.com" "$WORKDIR/deploy/.npmrc"
    grep -Fxq "registry=https://registry.npmjs.org" "$WORKDIR/deploy/.npmrc"
    grep -Fq "npm install" "$WORKDIR/pm-calls"
}

@test "install_pulumi_deps: uses yarn with a frozen lockfile when yarn.lock exists" {
    touch "$WORKDIR/deploy/yarn.lock"

    WORKING_DIRECTORY="$WORKDIR/deploy" GITHUB_PAT=secret-pat run bash "$SCRIPT"

    [ "$status" -eq 0 ]
    [ -f "$WORKDIR/deploy/.yarnrc" ]
    grep -Fq "registry \"https://registry.npmjs.org\"" "$WORKDIR/deploy/.yarnrc"
    grep -Fq -- "yarn install --frozen-lockfile" "$WORKDIR/pm-calls"
    ! grep -Fq "npm install" "$WORKDIR/pm-calls"
}

@test "install_pulumi_deps: does not write an npmrc registry line in the yarn branch" {
    touch "$WORKDIR/deploy/yarn.lock"

    WORKING_DIRECTORY="$WORKDIR/deploy" GITHUB_PAT=secret-pat run bash "$SCRIPT"

    [ "$status" -eq 0 ]
    grep -Fxq "//npm.pkg.github.com/:_authToken=secret-pat" "$WORKDIR/deploy/.npmrc"
    [ "$(wc -l < "$WORKDIR/deploy/.npmrc")" -eq 1 ]
}
