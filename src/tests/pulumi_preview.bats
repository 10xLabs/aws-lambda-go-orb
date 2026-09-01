#!/usr/bin/env bats

# Tests for src/scripts/pulumi_preview.sh
#
# `pulumi` is stubbed on PATH. The stub answers `stack ls` and serves a canned
# plan for `preview --json`, so the gate can be exercised without a backend.

setup() {
    SCRIPT="$BATS_TEST_DIRNAME/../scripts/pulumi_preview.sh"
    WORKDIR="$BATS_TEST_TMPDIR/$BATS_TEST_NAME"
    mkdir -p "$WORKDIR/stub"
    cd "$WORKDIR" || exit 1
    PATH="$WORKDIR/stub:$PATH"
    export WORKING_DIRECTORY=deploy
    export STACK_NAME=example.stag
    unset ALLOW_DESTROY
}

# stub_pulumi <plan-json> — the plan is returned by `preview --json`.
stub_pulumi() {
    echo "$1" > "$WORKDIR/plan.json"
    cat > "$WORKDIR/stub/pulumi" <<STUB
#!/usr/bin/env bash
case "\$1 \$2" in
    "stack ls") echo "$STACK_NAME*  now" ;;
    "preview --stack")
        if [[ " \$* " == *" --json "* ]]; then
            cat "$WORKDIR/plan.json"
        else
            echo "human-readable diff"
        fi
        ;;
    *) ;;
esac
STUB
    chmod +x "$WORKDIR/stub/pulumi"
}

plan_with() {
    printf '{"steps":[%s]}' "$1"
}

@test "preview: passes when the plan only creates and updates" {
    stub_pulumi "$(plan_with '
        {"op":"same","urn":"urn:pulumi:a::b::c::d"},
        {"op":"create","urn":"urn:pulumi:a::b::c::e"},
        {"op":"update","urn":"urn:pulumi:a::b::c::f"}
    ')"

    run bash "$SCRIPT"

    [ "$status" -eq 0 ]
    [[ "$output" == *"human-readable diff"* ]]
    [[ "$output" == *"No destructive changes"* ]]
}

@test "preview: fails and names the resource when the plan deletes one" {
    stub_pulumi "$(plan_with '
        {"op":"create","urn":"urn:pulumi:a::b::c::keep"},
        {"op":"delete","urn":"urn:pulumi:a::b::aws:s3/bucketObject:BucketObject::subgraph"}
    ')"

    run bash "$SCRIPT"

    [ "$status" -ne 0 ]
    [[ "$output" == *"destroys existing resources"* ]]
    [[ "$output" == *"subgraph"* ]]
}

@test "preview: fails on a replacement, which destroys the old resource" {
    stub_pulumi "$(plan_with '{"op":"replace","urn":"urn:pulumi:a::b::c::param"}')"

    run bash "$SCRIPT"

    [ "$status" -ne 0 ]
    [[ "$output" == *"param"* ]]
}

@test "preview: fails on delete-replaced, the form a replacement takes in the step list" {
    stub_pulumi "$(plan_with '
        {"op":"create-replacement","urn":"urn:pulumi:a::b::c::param"},
        {"op":"delete-replaced","urn":"urn:pulumi:a::b::c::param"}
    ')"

    run bash "$SCRIPT"

    [ "$status" -ne 0 ]
}

@test "preview: allow-destroy lets a deletion through" {
    stub_pulumi "$(plan_with '{"op":"delete","urn":"urn:pulumi:a::b::c::gone"}')"

    ALLOW_DESTROY=true run bash "$SCRIPT"

    [ "$status" -eq 0 ]
    [[ "$output" == *"allow-destroy is set"* ]]
}

@test "preview: reports the plan as empty rather than passing when steps are absent" {
    stub_pulumi '{}'

    run bash "$SCRIPT"

    [ "$status" -eq 0 ]
    [[ "$output" == *"No destructive changes"* ]]
}
