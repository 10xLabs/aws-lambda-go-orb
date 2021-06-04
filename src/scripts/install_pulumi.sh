if [ "$VERSION" == "latest" ]; then
    curl -L https://get.pulumi.com/ | bash -s
else
    curl -L https://get.pulumi.com/ | bash -s -- --version "$VERSION"
fi

echo "export PATH=${HOME}/.pulumi/bin:$PATH" >> "$BASH_ENV"

# shellcheck source=/dev/null
source "$BASH_ENV"

cd pulumi || exit
echo  "//npm.pkg.github.com/:_authToken=$NPM_GITHUB_TOKEN" > ./.npmrc
echo  "registry=$NPM_GITHUB_REGISTRY" >> ./.npmrc
npm install
