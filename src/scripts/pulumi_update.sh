if pulumi stack ls --cwd pulumi | grep -q ^"$STACK_NAME"; then
echo "exists"
else
echo "create"
pulumi stack init "$STACK_NAME" --cwd pulumi
fi
pulumi update --stack "$STACK_NAME" --cwd pulumi --yes
