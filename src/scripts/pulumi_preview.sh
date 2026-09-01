# shellcheck disable=SC2148
set -e

if pulumi stack ls --cwd "$WORKING_DIRECTORY" | grep -q ^"$STACK_NAME"; then
echo "stack exists"
else
echo "init stack"
pulumi stack init "$STACK_NAME" --cwd "$WORKING_DIRECTORY"
fi
pulumi preview --stack "$STACK_NAME" --cwd "$WORKING_DIRECTORY"

if [ "$ALLOW_DESTROY" = "true" ]; then
    echo "allow-destroy is set: not gating on destructive changes."
    exit 0
fi

if ! command -v jq > /dev/null 2>&1; then
    echo "Error: jq is required to inspect the plan. Set allow-destroy to skip this gate."
    exit 1
fi

# Second pass, machine-readable. --json replaces the diff above rather than adding to it,
# so the human-facing run is kept and this one only feeds the gate.
PLAN="$(mktemp)"
if ! pulumi preview --stack "$STACK_NAME" --cwd "$WORKING_DIRECTORY" --json > "$PLAN"; then
    echo "Error: could not produce a machine-readable plan to check for deletions."
    cat "$PLAN"
    exit 1
fi

DESTRUCTIVE="$(jq -r '
    [.steps[]? | select(.op == "delete" or .op == "replace" or .op == "delete-replaced")]
    | unique_by(.urn)
    | .[] | "  \(.op)\t\(.urn)"
' "$PLAN")"

if [ -n "$DESTRUCTIVE" ]; then
    echo
    echo "This plan destroys existing resources:"
    echo
    echo "$DESTRUCTIVE"
    echo
    echo "Destroying a resource discards whatever it holds -- stored objects, queued"
    echo "messages, parameter values. If every line above is intended, re-run with"
    echo "allow-destroy: true on the preview job."
    exit 1
fi

echo "No destructive changes in the plan."
