COMMIT_MESSAGE=$(git log -1 --pretty=format:"%s")
echo "$COMMIT_MESSAGE" | npx commitlint
