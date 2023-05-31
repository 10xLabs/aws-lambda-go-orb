# shellcheck disable=SC2148
if [ -n "$STACK_NAME" ]; then
    echo "export STACK_NAME=$STACK_NAME" >> "$BASH_ENV"
else
    echo "export STACK_NAME=$CIRCLE_PROJECT_REPONAME.$ENVIRONMENT" >> "$BASH_ENV"
fi
