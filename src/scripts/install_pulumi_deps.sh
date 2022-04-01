#! /bin/bash
cd "$WORKING_DIRECTORY" || exit
# echo  "registry=$NPM_GITHUB_REGISTRY" >> ./.npmrc
echo "registry=https://registry.npmjs.org/" >> ./.npmrc
echo  "@10xLabs:registry=$NPM_GITHUB_REGISTRY" >> ./.npmrc
echo  "//npm.pkg.github.com/:_authToken=$GITHUB_PAT" > ./.npmrc
pwd
cat ./.npmrc
ls -la
npm install
