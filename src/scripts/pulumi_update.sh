if pulumi stack ls --cwd deploy | grep -q ^"$STACK_NAME"; then
echo "exists"
else
echo "create"
pulumi stack init "$STACK_NAME" --cwd deploy
fi
pulumi update --stack "$STACK_NAME" --cwd deploy --yes
