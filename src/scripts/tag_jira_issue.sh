ISSUE_ID="NA-2175"
RELEASE_TAG="v1.0.0"

curl --request PUT \
  --url 'https://$JIRA_DOMAIN.atlassian.net/rest/api/3/issue/$ISSUE_ID' \
  --user '$JIRA_USER:$JIRA_TOKEN' \
  --header 'Accept: application/json' \
  --header 'Content-Type: application/json' \
  --data '{
            "update": {
              "labels": [
                {
                  "add": "$RELEASE_TAG"
                },
                {
                  "add": "$CIRCLE_PROJECT_REPONAME"
                }
              ]
            },
          }'
