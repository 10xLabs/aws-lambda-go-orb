# shellcheck disable=SC2148
set -e

PULUMI_BIN="$HOME/.pulumi/bin"

# The cache may already hold the requested version; only download when it does not.
if [ -x "$PULUMI_BIN/pulumi" ] && [ "$("$PULUMI_BIN/pulumi" version)" = "v$PULUMI_VERSION" ]; then
    echo "Pulumi v$PULUMI_VERSION restored from cache"
else
    echo "Installing Pulumi v$PULUMI_VERSION"
    curl -fsSL https://get.pulumi.com | sh -s -- --version "$PULUMI_VERSION"
fi

echo "export PATH=\"$PULUMI_BIN:\$PATH\"" >> "$BASH_ENV"
"$PULUMI_BIN/pulumi" version
