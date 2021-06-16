if pulumi stack ls --cwd pulumi | grep -q ^"$STACK_NAME"; then
echo "exists"
else
echo "create"
pulumi stack init "$STACK_NAME" --secrets-provider="awskms://alias/staging-PulumiSecrets?region=us-east-1" --cwd pulumi
fi
pulumi update --stack "$STACK_NAME" --secrets-provider="awskms://alias/staging-PulumiSecrets?region=us-east-1" --cwd pulumi --yes
