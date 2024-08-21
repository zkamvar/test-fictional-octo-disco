#!/bin/env bash
set -x
echo "AID: ${artifact_id:-missing}"
echo "Artifact URL: ${artifact_url:-missing}"
echo "Deploy ID: ${deploy_id:-missing}"
curl -L \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${GH_TOKEN}" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/${repo}/pages/deployments \
  -d '{"artifact_url":"'"${artifact_url}"'","environment":"github-pages","pages_build_version":"'"${deploy_id}"'","oidc_token":"'"${ID_TOKEN}"'","preview":false}'

