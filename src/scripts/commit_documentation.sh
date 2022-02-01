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

STATUS=$(git status)
echo "$STATUS"
echo "$STATUS" | grep "nothing to commit"
echo "................................................"

FILES=$(git diff --name-only)
echo "$FILES"
echo "................................................"
if [ -z "$FILES" ]; then
    echo "ENTRO AQUI"
    circleci-agent step halt
fi

git commit -m "docs: update $AGGREGATE_NAME module $MODULE_NAME"
git push --set-upstream origin "$CIRCLE_BRANCH"
