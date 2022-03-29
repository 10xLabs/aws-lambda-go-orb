#! /bin/bash
cd "$WORKING_DIRECTORY" || exit
echo  "//npm.pkg.github.com/:_authToken=$GITHUB_PAT" > ./.npmrc
echo  "registry=$NPM_GITHUB_REGISTRY" >> ./.npmrc
npm install
