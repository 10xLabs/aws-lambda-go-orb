#! /bin/bash
cd "$WORKING_DIRECTORY" || exit

echo  "//npm.pkg.github.com/:_authToken=$GITHUB_PAT" > ./.npmrc

if test -f "yarn.lock"; then
    echo  '"@10xLabs:registry" "https://npm.pkg.github.com"' > ./.yarnrc
    echo 'registry "https://registry.npmjs.org"' >> ./.yarnrc
    
    yarn install --frozen-lockfile --cache-folder ~/.cache/yarn
else
    echo  "@10xLabs:registry=$NPM_GITHUB_REGISTRY" >> ./.npmrc
    echo "registry=https://registry.npmjs.org" >> ./.npmrc
    
    npm install
fi
