# shellcheck disable=SC2148
set -e

GH_BIN="$HOME/.local/bin"

if [ -x "$GH_BIN/gh" ] && "$GH_BIN/gh" --version | grep -q "gh version $GH_VERSION"; then
    echo "GitHub CLI v$GH_VERSION restored from cache"
else
    case "$(uname -m)" in
        aarch64 | arm64) GH_ARCH=arm64 ;;
        x86_64) GH_ARCH=amd64 ;;
        *) echo "Unsupported architecture: $(uname -m)"; exit 1 ;;
    esac

    echo "Installing GitHub CLI v$GH_VERSION for linux_$GH_ARCH"
    mkdir -p "$GH_BIN"
    # The tarball is used rather than apt so the install needs no sudo and can be cached.
    curl -fsSL "https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_${GH_ARCH}.tar.gz" |
        tar -xz -C "$HOME/.local" --strip-components=1 "gh_${GH_VERSION}_linux_${GH_ARCH}/bin/gh"
fi

echo "export PATH=\"$GH_BIN:\$PATH\"" >> "$BASH_ENV"
"$GH_BIN/gh" --version
