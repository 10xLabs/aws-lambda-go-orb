# shellcheck disable=SC2148
FILES=$(git diff --name-only HEAD~1..HEAD "$MODULE_PATH")

if [ -z "$FILES" ]; then
    circleci-agent step halt
fi
