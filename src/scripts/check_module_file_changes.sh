FILES=$(git diff --name-only origin/master..origin/develop "$MODULE_PATH")

echo "...."
echo "$FILES"
echo "...."

[[ -z "${FILES// }" ]] && circleci-agent step halt
