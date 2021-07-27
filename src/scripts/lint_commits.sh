COMMITS=$(git log "origin/develop..origin/$CIRCLE_BRANCH" --pretty=format:%s)
echo "$CIRCLE_BRANCH"
echo "@@"
echo "$COMMITS"
echo "@@"
# shellcheck disable=SC2206
COMMIT_MESSAGES=(${COMMITS//\n/})
for COMMIT_MESSAGE in "${COMMIT_MESSAGES[@]}"
do
    echo ">>$COMMIT_MESSAGE<<"
    echo "$COMMIT_MESSAGE" | npx commitlint
done
