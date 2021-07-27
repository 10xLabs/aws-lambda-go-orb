COMMITS=$(git log "origin/develop..origin/$CIRCLE_BRANCH" --pretty=format:%s)
echo "$CIRCLE_BRANCH"
echo "@@"
echo "$COMMITS"
echo "@@"
IFS=$'\n' COMMIT_MESSAGES=($COMMITS)
for COMMIT_MESSAGE in "${COMMIT_MESSAGES[@]}"
do
    echo ">>$COMMIT_MESSAGE<<"
    echo "$COMMIT_MESSAGE" | npx commitlint
done
