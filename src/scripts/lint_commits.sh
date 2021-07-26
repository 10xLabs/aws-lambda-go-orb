COMMITS=$(git log "origin/$CIRCLE_BRANCH..origin/develop" --pretty=format:%s)
echo "$COMMITS"
echo "@@"
# shellcheck disable=SC2206
COMMIT_MESSAGES=(${COMMITS//\n/ })
for COMMIT_MESSAGE in "${COMMIT_MESSAGES[@]}"
do
    echo ">>$COMMIT_MESSAGE<<"
    echo "$COMMIT_MESSAGE" | npx commitlint
done
