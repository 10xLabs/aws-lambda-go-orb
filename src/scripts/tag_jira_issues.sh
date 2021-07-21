COMMIT_BODY=$(git log -1 origin/master --pretty=format:%b)
echo "$COMMIT_BODY"
echo "@@"
# shellcheck disable=SC2206
IFS=$'\n' COMMIT_MESSAGES=($COMMIT_BODY)
for COMMIT_MESSAGE in "${COMMIT_MESSAGES[@]}"
do
    echo "$COMMIT_MESSAGE"
    echo "@@"
    COMMIT_MESSAGE="$COMMIT_MESSAGE [NA-2272]"
    echo "$COMMIT_MESSAGE"
    echo "@@"
    if [[ "$COMMIT_MESSAGE" =~ \[([A-Z]{2,3}-[0-9]+)\] ]]; then
        ISSUE_ID="${BASH_REMATCH[1]}"
        curl --request PUT \
          --url "https://$JIRA_DOMAIN.atlassian.net/rest/api/3/issue/$ISSUE_ID" \
          --user "$JIRA_USER:$JIRA_TOKEN" \
          --header "Accept: application/json" \
          --header "Content-Type: application/json" \
          --data "{
                    \"update\": {
                      \"labels\": [
                        {
                          \"add\": \"$RELEASE_TAG\"
                        },
                        {
                          \"add\": \"$CIRCLE_PROJECT_REPONAME\"
                        }
                      ]
                    }
                  }"
        
        echo "The issue $ISSUE_ID has been tagged"
    fi
done
