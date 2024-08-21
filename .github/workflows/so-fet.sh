#!/bin/env bash
readarray -t ari < \
  <(curl --request GET \
  --header "Accept: application/vnd.github+json" \
  --header "Authorization: Bearer ${GH_TOKEN}" \
  --header "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/installation/repositories?per_page=100 \
  | jq -r .repositories[].full_name)

tmp=$(mktemp)
dir=$(mktemp -d)
cd "${dir}" || return
git config --global user.name "${SLUG}[bot]"
git config --global user.email "${ID}+${SLUG}[bot]@users.noreply.github.com>"
for repo in "${ari[@]}"
do
  gh repo clone "$repo" "$repo" -- --depth=1
  cd "${repo}" || return
  timestamp=$(date)
  head="
  <!DOCTYPE html>
  <html lang='en'>
  <head>
  <title>Generated Page</title>
  <meta charset='utf-8' />
  <!-- other meta, CSS, and custom tags -->
  </head>

  <body>
  <header>Generated Content</header>

  <main>
  <h1>Content From ${repo}</h1>
  <p>
  "
  body=${timestamp}'<br>'$(cat README.md)'</p>'
  code='<pre><code>'$(cat ./*.r)'</pre></code>'
  end='
  </main>
  <footer>Site Footer</footer>
  </body>
  </html>
  '
  echo "${head}${body}${code}${end}" > "${tmp}"
  cat "${tmp}"
  CURR_HEAD=$(git rev-parse HEAD)
  git checkout --orphan gh-pages
  git add -A
  git commit -m "source commit: ${CURR_HEAD}"
  ls -A | grep -v '^.git$' | xargs -I _ rm -r '_'
  cp "${tmp}" index.html
  git add -A
  git commit --allow-empty -m "auto commit"
    # --repo="https://${SLUG}${GH_TOKEN}@github.com/${repo}.git" \
  git push \
    -u \
    --force \
    --set-upstream \
    origin \
    gh-pages
  cd - || return
done
