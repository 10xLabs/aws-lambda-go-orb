# shellcheck disable=SC2148
set -e

CONFIG_PKG="node_modules/@commitlint/config-conventional/package.json"

# installed_version <package.json> — the version field, or nothing if absent.
installed_version() {
    [ -f "$1" ] || return 0
    sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$1" | head -1
}

# lint_commits.sh runs "npx commitlint", which resolves from node_modules when
# the packages are present and otherwise downloads them on every invocation.
# Both packages are checked: a cache entry for a different version must not be
# treated as a hit, or the pinned version is silently ignored.
CLI_VERSION=$(installed_version "node_modules/@commitlint/cli/package.json")
CONFIG_VERSION=$(installed_version "$CONFIG_PKG")

if [ "$CLI_VERSION" = "$COMMITLINT_VERSION" ] && [ "$CONFIG_VERSION" = "$COMMITLINT_VERSION" ]; then
    echo "commitlint $COMMITLINT_VERSION restored from cache"
else
    echo "Installing commitlint $COMMITLINT_VERSION"
    npm install --no-save --no-audit --no-fund \
        "@commitlint/cli@$COMMITLINT_VERSION" \
        "@commitlint/config-conventional@$COMMITLINT_VERSION"
fi

npx commitlint --version
