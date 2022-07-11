# GitHub action PoC
Repository to test the capabilities of GitHub action and how to manage them at scale.

# Executing GitHub actions

GitHub Actions are manually, scheduled, or even drive triggered. 
Any event defined at [Events that trigger workflows](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows)
can trigger a workflow.

* [Triggering a workflow](https://docs.github.com/en/actions/using-workflows/triggering-a-workflow)
* [inputs sample](.github/workflows/wf-inputs.yml)
* [Choosing GitHub-hosted runners](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#choosing-github-hosted-runners)
* [shell](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#jobsjob_idstepsshell)
* [Workflow Syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
* [Workflow Commands](https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions)
* [Caching dependencies to speed up workflows](https://docs.github.com/en/actions/using-workflows/caching-dependencies-to-speed-up-workflows)
* [Artifacts](https://docs.github.com/en/actions/using-workflows/storing-workflow-data-as-artifacts)
* [Approving workflow runs from public forks](https://docs.github.com/en/actions/managing-workflow-runs/approving-workflow-runs-from-public-forks)
* [Usage limits](https://docs.github.com/en/actions/learn-github-actions/usage-limits-billing-and-administration#usage-limits)
* [Default environment variables](https://docs.github.com/en/actions/learn-github-actions/environment-variables#default-environment-variables)
* [Contexts](https://docs.github.com/en/actions/learn-github-actions/contexts)

## Containers

On linux runners is possible to run Docker containers and run steps inside them.

* [Containers](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#jobsjob_idcontainer)

## Services

On linux runners is possible to run Docker containers and use then as services.

* [Services](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#jobsjob_idservices)

## Use other actions

Worlflows can use GitHub Actions as steps, these GitHub Actions come form the same repo, other repo, or a Docker image from any Docker registry.

* [steps.uses](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#jobsjob_idstepsuses)

# Secrets

## default GITHUB_TOKEN

An ephemeral GITHUB_TOKEN is is passed to the workflows if none is defined,
it makes easy to access to GitHub repository, 
however you must define the permissions of that GITHUB_TOKEN explicitly
to avoid surprises. By dafault it has only content read permission.

* [Automatic token authentication](https://docs.github.com/en/actions/security-guides/automatic-token-authentication)
* [Token access example](.github/workflows/token-access.yml)
* [Permissions](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#jobsjob_idpermissions)
* [Mask strings](https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#example-masking-a-string)

## Secret leaks

Like other CIs GitHub action has a feature to mask secrets in logs, 
when the value of the secret is found in the logs GitHub Action change the text to `****`,
however like in other CIs it is easy to by pass this protection midifiying the output in some way
to leak the password. 

* [Leak Secret](.github/workflows/leak-secret.yml)

## OpenID

* [About security hardening with OpenID Connect](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)
* [Configuring OpenID Connect in Google Cloud Platform](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-google-cloud-platform)
* [Configuring OpenID Connect in HashiCorp Vault](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-hashicorp-vault)

# Matrix execution support

It is possible to execute a set of steps based on a matrix of values, 
this use case is common to test something in different OS, 
or test a dependency on different versions. 

* [Matrix](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#jobsjob_idstrategymatrix)
* [Matrix sample](.github/workflows/matrix.yml)
* [Matrix Github Example](https://docs.github.com/en/actions/examples/using-concurrency-expressions-and-a-test-matrix)
* [Matrix of runners](.github/workflows/runners.yml)

# Reusing workflows

Reusing code is important, GitHub actions allow to define workflows that you can call from other workflows.
This feature has some limitation slike you can not call a reusable workflow from a reusable workflow,
but it is flexible enough to cover most of the cases. 

* Reusing workflows example [called](.github/workflows/reuse-wf-called.yml) and [caller](.github/workflows/reuse-wf-caller.yml)
* [Reusing workflows](https://docs.github.com/en/actions/using-workflows/reusing-workflows)
* [uses](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#jobsjob_idstepsuses)

# Other links

* [Skipping workflow runs](https://docs.github.com/en/actions/managing-workflow-runs/skipping-workflow-runs)
* [Deploying to Google Kubernetes Engine](https://docs.github.com/en/actions/deployment/deploying-to-your-cloud-provider/deploying-to-google-kubernetes-engine)


## Actions

* [github-script](https://github.com/actions/github-script) Write workflows scripting the GitHub API in JavaScript
* [file-changes-action](https://github.com/trilom/file-changes-action) get outputs of all of the files that have changed in your repository
* [cache](https://github.com/actions/cache) Cache dependencies and build outputs in GitHub Actions