#!/bin/bash
PULL_REQUEST_ID=$(gh pr list --base "master" --state "open" --limit 1 | awk '{split($0,a," "); print a[1]}')
PULL_REQUEST_TITLE="release $RELEASE_TAG"
PULL_REQUEST_BODY=$(git log origin/master..origin/develop --pretty=format:%s)

if [ -z "$PULL_REQUEST_ID" ]; then
    gh pr create --base master --title "$PULL_REQUEST_TITLE" --body "$PULL_REQUEST_BODY"
else
    gh pr edit "$PULL_REQUEST_ID" --title "$PULL_REQUEST_TITLE" --body "$PULL_REQUEST_BODY"
fi
