FILES=$(git diff --name-only origin/master..origin/develop "$MODULE_PATH")

if [ -z "$FILES" ]; then
    circleci-agent step halt
fi
