# shellcheck disable=SC2148
RELEASE_TAG="v1.0.0"

data=$(git tag --list --sort "-version:refname")
# shellcheck disable=SC2206
IFS=$'\n' tags=($data)

for tag in "${tags[@]}"
do
    if [[ $tag =~ ^$MODULE_NAME/v[0-9]+.[0-9]+.[0-9]+$ ]]; then
        version=${tag#"$MODULE_NAME/v"}
        # shellcheck disable=SC2206
        IFS=$'\n' tokens=($version)
        
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
        
        RELEASE_TAG="$MODULE_NAME/v$major.$minor.$patch"
        
        break
    fi
done

echo "export RELEASE_TAG=$RELEASE_TAG" >> "$BASH_ENV"
