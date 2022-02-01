# shellcheck disable=SC2148
cd /tmp || exit
git config --global user.name "Circle CI"
git config --global user.email "circleci@nexbus.com.mx"
git clone "https://$GITHUB_USER:$GITHUB_PAT@github.com/10xLabs/nexdocs.git"

cd nexdocs || exit
git checkout "$CIRCLE_BRANCH"

mkdir -p "aggregates/$AGGREGATE_NAME"
FILE_NAME=$(echo "$MODULE_NAME" | tr '[:upper:]' '[:lower:]')
mv "$DOCUMENTATION_FILE" "aggregates/$AGGREGATE_NAME/$FILE_NAME.md"
git add "aggregates/$AGGREGATE_NAME/$FILE_NAME.md"

FILES=$(git diff --name-only)
if [ -z "$FILES" ]; then
    circleci-agent step halt
    exit 0
fi

git commit -m "docs: update $AGGREGATE_NAME module $MODULE_NAME"
git push --set-upstream origin "$CIRCLE_BRANCH"
