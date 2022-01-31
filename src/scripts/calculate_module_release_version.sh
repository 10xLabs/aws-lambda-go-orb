# shellcheck disable=SC2148
echo "#0"
PRE_RELEASE="true"
if [ "$CIRCLE_BRANCH" = "master" ]; then
    PRE_RELEASE="false"
fi
echo "#1"
RELEASE_TAG="$MODULE_NAME/v1.0.0"
if [ "$PRE_RELEASE" = "true" ]; then
    RELEASE_TAG="$RELEASE_TAG-pre.0"
fi
echo "#2"
pre_number="0"
pre_version="v1.0.0"
echo "#3"
data=$(git tag --list "$MODULE_NAME/*" --sort "-version:refname")
if [ -z "$data" ]; then
    echo "export RELEASE_TAG=$RELEASE_TAG" >> "$BASH_ENV"
    return
fi
echo "#4"
echo "$MODULE_NAME"
echo "|$data|"
IFS=$'\n' read -rd '' -a tags <<<"$data"
echo "#5"
for tag in "${tags[@]}"
do
    echo "#6"
    echo "$tag"
    if [[ $tag =~ ^$MODULE_NAME/v[0-9]+.[0-9]+.[0-9]+$ ]]; then
        version=${tag#"$MODULE_NAME/v"}
        IFS=$'.' read -rd '' -a tokens <<<"$version"

        major="${tokens[0]}"
        minor="${tokens[1]}"
        patch="${tokens[2]}"

        case "$RELEASE_TYPE" in
            PATCH)
                patch=$((patch+1))
            ;;

            MINOR)
                minor=$((minor+1))
                patch="0"
            ;;

            MAJOR)
                major=$((major+1))
                minor="0"
                patch="0"
            ;;
        esac

        version="$major.$minor.$patch"
        if [ "$PRE_RELEASE" = "true" ]; then
            if [ "$version" = "$pre_version" ]; then
                pre_number=$((pre_number+1))
            else
                pre_number="0"
            fi
            version="$version-pre.$pre_number"
        fi
        RELEASE_TAG="$MODULE_NAME/v$version"

        break
    fi

    if [[ $pre_version == "v1.0.0" && $tag =~ ^$MODULE_NAME/v[0-9]+.[0-9]+.[0-9]+-pre.[0-9]+$ ]]; then
        pre_version=${tag#"$MODULE_NAME/v"}
        IFS=$'.' read -rd '' -a tokens <<<"$pre_version"
        pre_number="${tokens[3]}"
        pre_version=${pre_version%-pre*}
    fi
done

echo "export RELEASE_TAG=$RELEASE_TAG" >> "$BASH_ENV"
