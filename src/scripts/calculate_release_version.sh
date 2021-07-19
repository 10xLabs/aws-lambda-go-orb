COMMIT_MESSAGE=$(git log -1 origin/master --pretty=format:%s)
# shellcheck disable=SC2206
TOKENS=(${COMMIT_MESSAGE// / })
OLD_VERSION="${TOKENS[1]}"
# shellcheck disable=SC2206
TOKENS=(${OLD_VERSION//./ })

MAJOR="${TOKENS[0]:1}"
MINOR="${TOKENS[1]}"
PATCH="${TOKENS[2]}"

case "$RELEASE_TYPE" in

    PATCH)
    PATCH=$((PATCH+1))
    ;;

    MINOR)
    MINOR=$((MINOR+1))
    ;;

    MAJOR)
    MAJOR=$((MAJOR+1))
    ;;
esac

NEW_VERSION="v$MAJOR.$MINOR.$PATCH"

echo "RELEASE TYPE: $RELEASE_TYPE"
echo "OLD VERSION: $OLD_VERSION"
echo "NEW VERSION: $NEW_VERSION"

echo "export NEW_VERSION=$NEW_VERSION" >> "$BASH_ENV"
