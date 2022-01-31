#!/bin/bash
COMMIT_BODY=$(git log -1 origin/master --pretty=format:%b)
gh release create "$RELEASE_TAG" --notes "$COMMIT_BODY"
