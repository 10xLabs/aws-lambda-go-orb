# shellcheck disable=SC2148
COMMIT_SUBJECT=$(git log -1 origin/master --pretty=format:%s)
# shellcheck disable=SC2206
TOKENS=(${COMMIT_SUBJECT// / })
RELEASE_TAG="${TOKENS[1]}"

echo "$RELEASE_TAG"
echo "$COMMIT_SUBJECT"

git config --global user.name "Circle CI"
git config --global user.email "circleci@nexbus.com"
git remote set-url origin "https://$GITHUB_USER:$GITHUB_PAT@github.com/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME.git"

git tag -a "$RELEASE_TAG" -m "$COMMIT_SUBJECT"
git push origin "$RELEASE_TAG"

echo "export RELEASE_TAG=$RELEASE_TAG" >> "$BASH_ENV"
