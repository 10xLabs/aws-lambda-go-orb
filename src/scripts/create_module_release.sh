#!/bin/bash
COMMITS=$(git log HEAD~1..HEAD --pretty=format:%s -- "$MODULE_PATH")

if [ "$CIRCLE_BRANCH" = "master" ]; then
    gh release create "$RELEASE_TAG" --notes "$COMMITS"
else
    gh release create "$RELEASE_TAG" --notes "$COMMITS" --prerelease
fi
