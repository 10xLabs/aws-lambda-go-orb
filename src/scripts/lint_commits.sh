if [[ "$CIRCLE_BRANCH" != "master" ]]; then
    # shellcheck disable=SC2148
    COMMITS=$(git log "origin/develop..origin/$CIRCLE_BRANCH" --pretty=format:%s)
    # shellcheck disable=SC2206
    IFS=$'\n' COMMIT_MESSAGES=($COMMITS)
    for COMMIT_MESSAGE in "${COMMIT_MESSAGES[@]}"; do
        echo "$COMMIT_MESSAGE" | npx commitlint
    done
fi
