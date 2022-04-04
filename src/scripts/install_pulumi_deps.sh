#! /bin/bash
cd "$WORKING_DIRECTORY" || exit

echo  "//npm.pkg.github.com/:_authToken=$GITHUB_PAT" > ./.npmrc

npm install
