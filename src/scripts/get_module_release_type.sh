# shellcheck disable=SC2148
RELEASE_TYPE="PATCH"
PULL_REQUEST_BODY=$(git log origin/master..origin/develop --pretty=format:%s -- "$MODULE_PATH")
if [ "$CIRCLE_BRANCH" == "master" ]; then
    PULL_REQUEST_BODY=$(git log HEAD...HEAD~1 --pretty=format:%s -- "$MODULE_PATH")
fi
# shellcheck disable=SC2206
IFS=$'\n' COMMIT_MESSAGES=($PULL_REQUEST_BODY)
for COMMIT_MESSAGE in "${COMMIT_MESSAGES[@]}"; do
    TYPE=${COMMIT_MESSAGE%:*}
    if [ "${TYPE:(-1)}" = "!" ]; then
        RELEASE_TYPE="MAJOR"
    fi
    if [[ "${TYPE:0:4}" = "feat" && "$RELEASE_TYPE" != "MAJOR" ]]; then
        RELEASE_TYPE="MINOR"
    fi
done

echo "export RELEASE_TYPE=$RELEASE_TYPE" >>"$BASH_ENV"
