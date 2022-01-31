#!/bin/bash
RELEASE_TYPE="PATCH"
PULL_REQUEST_BODY=$(git log HEAD~1..HEAD --pretty=format:%s -- "$MODULE_PATH")
# shellcheck disable=SC2206
IFS=$'\n' COMMIT_MESSAGES=($PULL_REQUEST_BODY)
for COMMIT_MESSAGE in "${COMMIT_MESSAGES[@]}"
do
    # shellcheck disable=SC2206
    TOKENS=(${COMMIT_MESSAGE//:/ })
    TYPE="${TOKENS[0]}"
    if [ "${TYPE:(-1)}" = "!" ]; then
        RELEASE_TYPE="MAJOR"
    fi
    if [[ "${TYPE:0:4}" = "feat" && "$RELEASE_TYPE" != "MAJOR" ]]; then
        RELEASE_TYPE="MINOR"
    fi
done

echo "export RELEASE_TYPE=$RELEASE_TYPE" >> "$BASH_ENV"
