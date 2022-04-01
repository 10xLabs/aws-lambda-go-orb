#! /bin/bash
cd "$WORKING_DIRECTORY" || exit
echo -e "registry=$NPM_GITHUB_REGISTRY\n//npm.pkg.github.com/:_authToken=$GITHUB_PAT" > ./.npmrc
# echo  "registry=$NPM_GITHUB_REGISTRY" >> ./.npmrc
pwd
ls -la
npm install
