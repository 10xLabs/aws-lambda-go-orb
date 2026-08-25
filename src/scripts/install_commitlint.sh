# shellcheck disable=SC2148
set -e

# lint_commits.sh runs "npx commitlint", which resolves from node_modules when
# the packages are present and otherwise downloads them on every invocation.
if [ -x "node_modules/.bin/commitlint" ]; then
    echo "commitlint restored from cache"
else
    echo "Installing commitlint $COMMITLINT_VERSION"
    npm install --no-save --no-audit --no-fund \
        "@commitlint/cli@$COMMITLINT_VERSION" \
        "@commitlint/config-conventional@$COMMITLINT_VERSION"
fi

npx commitlint --version
