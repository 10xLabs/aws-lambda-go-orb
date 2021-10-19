LAST_RELEASE_TAG=$(git tag --list "$MODULE_NAME/*" --sort "version:refname" | tail -1)

RELEASE_TAG="$MODULE_NAME/v1.0.0"

if [[ $LAST_RELEASE_TAG =~ ^$MODULE_NAME/v[0-9]+.[0-9]+.[0-9]+$ ]]; then
    LAST_VERSION=${LAST_RELEASE_TAG#"$MODULE_NAME/v"}
    TOKENS=(${LAST_VERSION//./ })
    
    MAJOR="${TOKENS[0]}"
    MINOR="${TOKENS[1]}"
    PATCH="${TOKENS[2]}"
    
    case "$RELEASE_TYPE" in
        PATCH)
            PATCH=$((PATCH+1))
        ;;
        
        MINOR)
            MINOR=$((MINOR+1))
            PATCH="0"
        ;;
        
        MAJOR)
            MAJOR=$((MAJOR+1))
            MINOR="0"
            PATCH="0"
        ;;
    esac
    
    RELEASE_TAG="$MODULE_NAME/v$MAJOR.$MINOR.$PATCH"
fi

echo "export RELEASE_TAG=$RELEASE_TAG" >> "$BASH_ENV"
