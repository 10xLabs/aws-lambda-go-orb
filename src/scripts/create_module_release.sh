COMMITS=$(git log HEAD~1..HEAD --pretty=format:%s -- "$MODULE_PATH")
gh release create "$RELEASE_TAG" --notes "$COMMITS"
