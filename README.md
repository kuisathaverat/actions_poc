# GitHub action PoC
Repository to test the capabilities of GitHub action and how to manage them at scale.

# Executing GitHub actions

GitHub Actions are manually, scheduled, or even drive triggered. 
Any event defined at [Events that trigger workflows](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows)
can trigger a workflow.

* [starter-workflows](https://github.com/actions/starter-workflows) These are the workflow files for helping people get started with GitHub Actions.
* [Triggering a workflow](https://docs.github.com/en/actions/using-workflows/triggering-a-workflow)
* [inputs example](.github/workflows/wf-inputs.yml)
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
* [Expresions](https://docs.github.com/en/actions/learn-github-actions/expressions)

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

### GCP
* create a user account with permissions to the services needed (e.g. Compute Engine admin)
* Create a Workload Identity Pools (IAM & admin/Workload Identity Pools)
    * name: GitHub Actions OIDC token
    * id: github-actions-oidc-token
    * issuer: https://token.actions.githubusercontent.com
    * Audiences: Default audience
    * Attribute Mapping:
        * google.subject: 'repo:kuisathaverat/actions_poc:ref:refs/heads/main'
* Add the service account to the Workload Identity Pools (IAM & admin/Workload Identity Pools/GitHub Action identity pool pool details)

### Vault

In order to make some test, I have configured a HashiCorp Vault service on a VM in CGP.
First of all we have to launch a VM and install HashiCorp Vault,
for our test a `e2-micro` machine running Debian 10 is enough for our service.
To install vault we can follow one of this tutorials [Web UI](https://learn.hashicorp.com/tutorials/vault/getting-started-ui?in=vault/getting-started), 
or [DEploy Vault](https://learn.hashicorp.com/tutorials/vault/getting-started-deploy?in=vault/getting-started).
Try to configure everythin from the host conlose due the service does not have TSL enabled yet.
We need a firewall rule to allow inbound TCP traffic to the port 8200 of the VM.
The next step is to get a valid TSL certificate to run the server with TLS,
the easy way is to use [certbot](https://certbot.eff.org/instructions?ws=other&os=debianbuster) to issue a certificate from [let's encrypt](https://letsencrypt.org/). You need a DNS name in order to issue the certificate so you can use `<IP>.nip.io` as a DNS name, 
the `.nip.io` service will resolve the IP of your VM like a regular DNS.
When you have the certificate you can edit the configuration of Vault to use TSL.
```
ui = true
disable_mlock = true

storage "raft" {
  path    = "./vault/data"
  node_id = "node1"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = "false"
  tls_cert_file = "/home/user/fullchain.pem"
  tls_key_file  = "/home/user/privkey.pem"
}

api_addr = "http://127.0.0.1:8200"
cluster_addr = "https://127.0.0.1:8201"
```

From this point, you can use the UI to create a kv v2 secret engine,
and some secrets to get from the GitHub Actions.
We have everything ready to start.

[hashicorp/vault-action](https://github.com/hashicorp/vault-action) require to enable JWT authentication.

```bash
export VAULT_ADDR=http://127.0.0.1:8200
vault login
vault auth enable jwt
```

When you have JWT authentication enabled you will need to configure the JWT with the following command

```bash
vault write auth/jwt/config \
    oidc_discovery_url='https://token.actions.githubusercontent.com' \
    bound_issuer='https://token.actions.githubusercontent.com'
```

finally you have to create a JWT role, 
the important parameter here is the `bound_subject` that match with the `sub` attribute in the GitHub action request 
(see [About security hardening with OpenID Connect](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect) and [JWT with GitHub OIDC Tokens](https://github.com/hashicorp/vault-action#jwt-with-github-oidc-tokens))

```bash
vault delete auth/jwt/role/githubactions
vault write auth/jwt/role/githubactions \
    role_type='jwt' \
    bound_subject='repo:kuisathaverat/actions_poc:ref:refs/heads/main' \
    bound_audiences='https://github.com/kuisathaverat' \
    user_claim='repository' \
    policies='default'
```

This is an alternative configuration that uses `bound_claims` with a wildcard value instead `bound_subject` to filter the requests.
Note that the payload is JSON due a [bug with the maps in the commandline attributes](https://github.com/hashicorp/vault-plugin-auth-jwt/issues/68)
```bash
vault delete auth/jwt/role/githubactions
vault write auth/jwt/role/githubactions -<<EOF
{
    "role_type": "jwt",
    "bound_claims": {
        "sub": "repo:kuisathaverat/*"
    },
    "bound_claims_type": "glob",
    "bound_audiences": "https://github.com/kuisathaverat",
    "user_claim": "repository"
}
EOF
```

* [OpenID Vault example](.github/workflows/openID-vault.yml)
* [About security hardening with OpenID Connect](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)
* [Configuring OpenID Connect in Google Cloud Platform](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-google-cloud-platform)
* [Configuring OpenID Connect in HashiCorp Vault](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-hashicorp-vault)

notes:
* cubbyhole engine is not accesible from the action
* Vault path for the engine kv v2 are like <engine name>/data/<path>

# Matrix execution support

It is possible to execute a set of steps based on a matrix of values, 
this use case is common to test something in different OS, 
or test a dependency on different versions. 

* [Matrix](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#jobsjob_idstrategymatrix)
* [Matrix example](.github/workflows/matrix.yml)
* [Matrix Github Example](https://docs.github.com/en/actions/examples/using-concurrency-expressions-and-a-test-matrix)
* [Matrix of runners](.github/workflows/runners.yml)

# Reusing workflows

Reusing code is important, GitHub actions allow to define workflows that you can call from other workflows.
This feature has some limitation slike you can not call a reusable workflow from a reusable workflow,
but it is flexible enough to cover most of the cases. 

* Reusing workflows example [called](.github/workflows/reuse-wf-called.yml) and [caller](.github/workflows/reuse-wf-caller.yml)
* [Reusing workflows](https://docs.github.com/en/actions/using-workflows/reusing-workflows)
* [uses](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#jobsjob_idstepsuses)

# Building Custom GitHub Actions

Another way to exted GitHub action is to create GitHub Action,
A gitHub Action could be something as simple as a Docker container or an script.
In this PoC we have converted the logic we use to generate a Runner Token to a GitHub Action,
we have made a Docker version and a composite version.

A Composite GitHub Actions and use other GitHub Actions, 
this make possible to bundle funcionality or wrap other GitHub Actions.
In the composite example we have used a bash script,
but is possible to use any shell or script language supported (bash, powershell, Python, Node.js, ...).
Python is probably a good candidate, it is a good script language, 
with it has tons of libraries, and support for unit tests.

* [Get Runner Token GitHub Action Composite version](.github/actions/get-runner-token)
* [Get Runner Token GitHub Action Docker version](.github/actions/get-runner-token-docker)
* [Creating a Docker container action](https://docs.github.com/en/actions/creating-actions/creating-a-docker-container-action)
* [Creating a composite action](https://docs.github.com/en/actions/creating-actions/creating-a-composite-action)
* [Metadata syntax for GitHub Actions](https://docs.github.com/en/actions/creating-actions/metadata-syntax-for-github-actions)

# Self-hosted runners

It is possible to use self-hosted runners, these runners are any kind of VM/machine/pod/... 
that can run the [runner app](https://github.com/actions/runner).
It is easy to provision a runner inside the same workflow you are running and deprovision it at the end of the workflow,
also there are several implementations to provision runners on diferent cloud providers based on a GitHub app to request the provision/deprovision.
In the PoC we have implemented 3 ways to deploy a runner:
* [On demand GCP runner example](.github/workflows/custom-runner-gcp.yml)
* [On demand GKE runner example](.github/workflows/k8s-runner-gke.yml)
* [On demand GCP runner example ussing an Action](.github/workflows/gce-github-runner.yml)
* [Runner Docker container](.github/docker/runner)

The three ways use the workflow pattern provision->build->deprovision, 
this approacha can apply to any Cloud provider,
To provision operation you can use a CLI tool, Terraform, or other way to provision resources.
In the k8s example, we use a Docker container with the runner installed along witha a k8s manifest file to define runner pod.
To make the deploy `kubeclt` is the tools used to provision and deprovision the pod.

* [About self-hosted runners](https://docs.github.com/en/actions/hosting-your-own-runners/about-self-hosted-runners)
* [actions-runner-controller](https://github.com/actions-runner-controller/actions-runner-controller) This controller operates self-hosted runners for GitHub Actions on your Kubernetes cluster.
* [terraform-aws-github-runner](https://github.com/philips-labs/terraform-aws-github-runner) This Terraform module creates the required infrastructure needed to host GitHub Actions self-hosted, auto-scaling runners on AWS spot instances.
* [Terraform / Packer project for scalable self hosted GitHub action runners on GCP](https://github.com/faberNovel/terraform-gcp-github-runner) This project leverages Terraform and Packer to deploy and maintain scalable self hosted GitHub actions runners infrastructure on GCP for a GitHub organization.
* [gce-github-runner](https://github.com/related-sciences/gce-github-runner) Ephemeral GCE GitHub self-hosted runner.
* [orka-actions-up](https://github.com/marketplace/actions/orka-actions-up) Run self-hosted, macOS workflows on MacStadium's Orka.

# Features 

* Simple
* Zero learn curve
* Marketplace with a huge action alredy implemented
* Strong comunnity
* Overall well Documented
* GitHub integration
* Security managed along with GitHub access
* Linux/Windows/masOS runners support
* Easy tooling manage (Go, Node.js, Java, Docker,...)
* GCP/Azure/AWS/Vault OpenID integration
* ONPrem runners support
* Kubernetes runners implemented
* AWS runners implemented
* Orka runners implemented
* Cache support for the most common build systems
* Reusable blocks of code (library of action/workflows)
* Library code support unit tests
* Matrix jobs execution native support
* Container services support
* Public/private Artifact repository (GitHub packages)
* Public/private Docker registry (GitHub packages)
* Mask secrets support
* Logs messages group support


# Other links

* [Keeping your GitHub Actions and workflows secure Part 1: Preventing pwn requests](https://securitylab.github.com/research/github-actions-preventing-pwn-requests/)
* [Skipping workflow runs](https://docs.github.com/en/actions/managing-workflow-runs/skipping-workflow-runs)
* [Deploying to Google Kubernetes Engine](https://docs.github.com/en/actions/deployment/deploying-to-your-cloud-provider/deploying-to-google-kubernetes-engine)
* [Working with the Container registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
* [Connecting a repository to a user-owned package on GitHub](https://docs.github.com/en/packages/learn-github-packages/connecting-a-repository-to-a-package)
* [Upgrading a workflow that accesses ghcr.io](https://docs.github.com/en/packages/managing-github-packages-using-github-actions-workflows/publishing-and-installing-a-package-with-github-actions#upgrading-a-workflow-that-accesses-ghcrio)
* [Migrating from Jenkins to GitHub Actions](https://docs.github.com/en/actions/migrating-to-github-actions/migrating-from-jenkins-to-github-actions)
* [Adding a workflow status badge](https://docs.github.com/en/actions/monitoring-and-troubleshooting-workflows/adding-a-workflow-status-badge)
* [Enabling debug logging](https://docs.github.com/en/actions/monitoring-and-troubleshooting-workflows/enabling-debug-logging)
* [Notifications for workflow runs](https://docs.github.com/en/actions/monitoring-and-troubleshooting-workflows/notifications-for-workflow-runs)
* [GitHub Actions self-hosted runners on Google Cloud](https://github.blog/2020-08-04-github-actions-self-hosted-runners-on-google-cloud/)
* [Security hardening for GitHub Actions](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions)

## Actions

* [github-script](https://github.com/actions/github-script) Write workflows scripting the GitHub API in JavaScript
* [file-changes-action](https://github.com/trilom/file-changes-action) get outputs of all of the files that have changed in your repository
* [cache](https://github.com/actions/cache) Cache dependencies and build outputs in GitHub Actions
* [docker/metadata-action](https://github.com/docker/metadata-action) GitHub Action to extract metadata from Git reference and GitHub events.
* [docker/build-push-action](https://github.com/docker/build-push-action) GitHub Action to build and push Docker images with Buildx with full support of the features provided by Moby BuildKit builder toolkit. 
* [docker/setup-qemu-action](https://github.com/docker/setup-qemu-action) GitHub Action to install QEMU static binaries.
* [setup-buildx-action](https://github.com/docker/setup-buildx-action) GitHub Action to set up Docker Buildx.
* [docker/login-action](https://github.com/docker/login-action) GitHub Action to login against a Docker registry.
* [create-or-update-comment](https://github.com/peter-evans/create-or-update-comment) A GitHub action to create or update an issue or pull request comment.
* [actions/stale](https://github.com/actions/stale) Warns and then closes issues and PRs that have had no activity for a specified amount of time.
* [labeler](https://github.com/andymckay/labeler) Automatically adds or removes labels from issues, pull requests and project cards.
Actions on your Kubernetes cluster.
* [ossf-scorecard-action](https://github.com/marketplace/actions/ossf-scorecard-action) Official GitHub Action for OSSF Scorecards.
* [rotate-gcp-service-account-keys](https://github.com/marketplace/actions/rotate-gcp-service-account-keys) This action rotates GCP service account keys.
* [google-github-actions/get-gke-credentials](https://github.com/google-github-actions/get-gke-credentials) This action configures authentication to a GKE cluster via a kubeconfig file that can be used with kubectl or other methods of interacting with the cluster.
* [actions/snyk](https://github.com/marketplace/actions/snyk) A set of GitHub Action for using Snyk to check for vulnerabilities in your GitHub projects.
* [actions/kubernetes-security-config-watch](https://github.com/marketplace/actions/kubernetes-security-config-watch) This Git Action run security lint check against Kubernetes workloads in Git workflow (PR open, commit pushed etc.).
* [actions/hashicorp-setup-terraform](https://github.com/marketplace/actions/hashicorp-setup-terraform) The hashicorp/setup-terraform action is a JavaScript action that sets up Terraform CL.
* [actions/packer-github-actions](https://github.com/marketplace/actions/packer-github-actions) GitHub Action for running Packer commands.
* [actions/slack-send](https://github.com/marketplace/actions/slack-send) Send data into Slack using this GitHub Action! 
* [actions/jenkinsfile-runner-prepackaged](https://github.com/marketplace/actions/jenkinsfile-runner-prepackaged) This is a POC how to run Jenkinsfiles inside GitHub Actions.

