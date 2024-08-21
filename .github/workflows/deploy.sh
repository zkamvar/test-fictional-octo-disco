#!/bin/env bash
echo "AID: ${artifact_id:-missing}"
echo "Deploy ID: ${deploy_id:-missing}"
curl -L \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer <YOUR-TOKEN>" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/${repo}/pages/deployments \
  -d '{"artifact_id":"'"${artifact_id}"'","environment":"github-pages","pages_build_version":"'"${deploy_id}"'","oidc_token":"'"${ACTIONS_ID_TOKEN_REQUEST_TOKEN}"'","preview":false}'

