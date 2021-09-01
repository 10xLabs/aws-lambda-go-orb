if pulumi stack ls --cwd "$WORKING_DIRECTORY" | grep -q ^"$STACK_NAME"; then
echo "stack exists"
else
echo "init stack"
pulumi stack init "$STACK_NAME" --cwd "$WORKING_DIRECTORY" --yes
fi
pulumi update --stack "$STACK_NAME" --cwd "$WORKING_DIRECTORY" --yes
