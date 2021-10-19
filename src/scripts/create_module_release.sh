COMMITS=$(git log origin/master..origin/develop --pretty=format:%s -- "$MODULE_PATH")
gh release create "$RELEASE_TAG" --notes "$COMMITS"
