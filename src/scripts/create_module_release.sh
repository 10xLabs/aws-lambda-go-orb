# shellcheck disable=SC2148
COMMITS=$(git log origin/master..origin/develop --pretty=format:%s -- "$MODULE_PATH")

if [ "$CIRCLE_BRANCH" = "master" ]; then
    gh release create "$RELEASE_TAG" --notes "$COMMITS"
else
    gh release create "$RELEASE_TAG" --notes "$COMMITS" --prerelease
fi
