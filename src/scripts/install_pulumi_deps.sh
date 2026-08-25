#!/bin/bash
set -e

cd "$WORKING_DIRECTORY" || exit

# Validate that required environment variables are set
if [ -z "$GITHUB_PAT" ]; then
    echo "Error: GITHUB_PAT environment variable is not set"
    exit 1
fi

echo "//npm.pkg.github.com/:_authToken=$GITHUB_PAT" > ./.npmrc

if test -f "yarn.lock"; then
    echo  '"@10xLabs:registry" "https://npm.pkg.github.com"' > ./.yarnrc
    echo 'registry "https://registry.npmjs.org"' >> ./.yarnrc
    
    yarn install --frozen-lockfile --cache-folder ~/.cache/yarn
else
    echo  "@10xLabs:registry=$NPM_GITHUB_REGISTRY" >> ./.npmrc
    echo "registry=https://registry.npmjs.org" >> ./.npmrc
    
    npm install
fi
