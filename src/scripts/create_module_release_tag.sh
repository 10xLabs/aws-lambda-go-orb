# shellcheck disable=SC2148
git config --global user.name "Circle CI"
git config --global user.email "circleci@nexbus.com.mx"
git remote set-url origin "https://$GITHUB_USER:$GITHUB_PAT@github.com/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME.git"

git tag -a "$RELEASE_TAG" -m "release $RELEASE_TAG"
git push origin "$RELEASE_TAG"
