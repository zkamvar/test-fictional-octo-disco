## GitHub App Testing

This is testing how a GitHub App works.

Goal: provide a service that will build a templated GitHub pages site for
repositories that have this app installed without requiring the admin for the
site to maintain a GitHub Workflow and without requiring hosting on an external
service like AWS.

Problem: We want to allow people to put markdown files in a folder and get a
website for their hubverse hub that contains predtimechart and evaluations
without needing to store templated data or navigate complex directories required
by static site generators. A setup like this normally requires github workflows
to live in the repository, like [The Carpentries
Workbench](https://carpentries.github.io/workbench). The problem with this
approach: it becomes difficult to update these workflows when something needs to
change. 


I was able to set up a proof of concept GitHub app (it's private and called
"macrohard-onfire-goggles") on my account. It shows that we can centralize the
build process without requiring hub maintainers to add yet another GitHub
Workflow. This also has implications for the workflows to validate hubs as we
can potentially centralize those as well.

I installed this app on two repositories (one public, one private) and use it
to automatically update their gh-pages branch without having GitHub Actions
enabled on those repositories. The public repo is
https://github.com/zkamvar/CardTrick and the generated github page is
https://zkamvar.github.io/CardTrick/

To do this, I created a separate test repository where I added the App ID and
private key and then created a workflow that would generate a token, fetch the
repositories that had the app installed, generated the pages, and force-pushed
them to gh-pages:
https://github.com/zkamvar/test-fictional-octo-disco/blob/main/.github/workflows/outside-pages.yml

Note that this app does not necessarily have to have write access to the
repositories. We could have it update the pages deployment without touching a
branch (though I need to dig a bit deeper into the GitHub API for that), or we
could push the site to AWS S3.

Much of the prior art comes from how the r-universe works in that it does not
require users to set up GitHub actions to run everything:
https://github.com/r-universe-org/control-room/
