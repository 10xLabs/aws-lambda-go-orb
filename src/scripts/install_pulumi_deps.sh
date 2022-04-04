#! /bin/bash
cd "$WORKING_DIRECTORY" || exit

{
  echo "registry=https://registry.npmjs.org/"
   "@10xLabs:registry=$NPM_GITHUB_REGISTRY"
   "//npm.pkg.github.com/:_authToken=$GITHUB_PAT" 
} >> ./.npmrc

npm install
