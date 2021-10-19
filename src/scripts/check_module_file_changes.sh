CHANGED_FILES=$(git diff --name-only HEAD~1..HEAD "$MODULE_PATH")

echo "...."
echo "$CHANGED_FILES"
echo "...."

[[ -z "${CHANGED_FILES// }" ]] && circleci-agent step halt
