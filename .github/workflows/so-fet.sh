#!/bin/env bash

# FETCH REPOSITORIES THAT HAVE INSTALLED OUR APP
# ==============================================
# 
# When someone installs the app to their repository, we can use this to grab
# all the repositories where the app is installed, so we can loop through them
readarray -t ari < \
  <(curl --request GET \
  --header "Accept: application/vnd.github+json" \
  --header "Authorization: Bearer ${GH_TOKEN}" \
  --header "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/installation/repositories?per_page=100 \
  | jq -r .repositories[].full_name)

# CLONE THE REPOS, DO STUFF, AND PUSH
# ===================================
#
# Here is an example of what we can do with the repositories.
# NOTE: We have explicit content writing permissions for the app, but this does
# not have to be the case. We could use the GitHub API to deploy the site (but
#
tmp=$(mktemp)
dir=$(mktemp -d)
cd "${dir}" || return
git config --global user.name "${SLUG}[bot]"
git config --global user.email "${ID}+${SLUG}[bot]@users.noreply.github.com"
for repo in "${ari[@]}"
do
  # https://docs.github.com/en/apps/creating-github-apps/authenticating-with-a-github-app/authenticating-as-a-github-app-installation
  # You can also use an installation access token to authenticate for
  # HTTP-based Git access. Your app must have the "Contents" repository
  # permission. You can then use the installation access token as the HTTP
  # password. Replace TOKEN with the installation access token: git clone
  # https://x-access-token:TOKEN@github.com/owner/repo.git.
  git clone --depth=1 \
    "https://x-access-token:${GH_TOKEN}@github.com/${repo}.git" \
    "${repo}"
  cd "${repo}" || return
  echo "build_version: ${GITHUB_SHA}"
  echo "commit       : $(git rev-parse HEAD)"
  git config --list
  git remote -v
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
  <h2>Bot Information</h2>
  <pre>
  $(gh auth status)
  </pre>
  <h2>Context</h2>
  <pre>
  ${CONTEXT}
  </pre>
  <h2>README.md</h2>
  <p>
  "
  body="${timestamp}<br>$(sed 's/$/<br>/g' < README.md)</p>"
  code='<pre><code>'$(cat ./*.r)'</pre></code>'
  end='
  </main>
  <footer>Site Footer</footer>
  </body>
  </html>
  '
  echo "${head}${body}${code}${end}" > "${tmp}"
  CURR_HEAD=$(git rev-parse HEAD)
  git checkout --orphan gh-pages
  git add -A
  git commit -m "source commit: ${CURR_HEAD}"
  ls -A | grep -v '^.git$' | xargs -I _ rm -r '_'
  cp "${tmp}" index.html
  git add -A
  git commit --allow-empty -m "auto commit"
  git push \
    -u \
    --force \
    --set-upstream \
    origin \
    gh-pages
  cd - || return
done
