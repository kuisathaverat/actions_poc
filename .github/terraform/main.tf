terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 4.0"
    }
  }
}

# Configure the GitHub Provider
provider "github" {
    #token = var.token # or `GITHUB_TOKEN`
    owner = var.owner # or `GITHUB_OWNER`
}

## Repositories management

# Create a repository template
resource "github_repository" "template" {
    name = "template"
    description = "This is my first repository"
    visibility = "private"
    is_template = true
    vulnerability_alerts  = true
    license_template  = "Apache-2.0"
    allow_auto_merge  = true
    auto_init = true
}

# add repository branch protection
resource "github_branch_protection" "template" {
  repository_id  = github_repository.tf_repo00.name
  pattern          = "main"
  enforce_admins   = true
  allows_deletions = true

  required_status_checks {
    strict   = true
    contexts = ["ci"]
  }

  required_pull_request_reviews {
    require_code_owner_reviews  = true
    required_approving_review_count    = 2
  }
}

# Create a new repository
resource "github_repository" "tf_repo00" {
    name = "tf-repo00"
    description = "This is my first repository"
    template {
        owner = var.owner
        repository = github_repository.template.name
    }
}

# create a new repository branch
resource "github_branch" "tf_repo00_main" {
  repository = github_repository.tf_repo00.name
  branch     = "main"
}

# create a new repository branch
resource "github_branch" "tf_repo00_development" {
  repository = github_repository.tf_repo00.name
  branch     = "development"
}

# set default repository branch
resource "github_branch_default" "tf_repo00_default"{
  repository = github_repository.tf_repo00.name
  branch     = github_branch.tf_repo00_main.branch
}

# creaate a new repository
resource "github_repository" "tf_repo01" {
    name = "tf-repo01"
    description = "This is my second repository"
    template {
        owner = var.owner
        repository = github_repository.template.name
    }
}

# create a new repository branch
resource "github_branch" "tf_repo01_main" {
  repository = github_repository.tf_repo01.name
  branch     = "main"
}

# create a new repository branch
resource "github_branch" "tf_repo01_development" {
  repository = github_repository.tf_repo01.name
  branch     = "development"
}

# set default repository branch
resource "github_branch_default" "tf_repo01_default"{
  repository = github_repository.tf_repo01.name
  branch     = github_branch.tf_repo01_main.branch
}

## Teams management

# Add a team to the organization
resource "github_team" "omac_team" {
  name        = "omac-team"
  description = "One Man Army Corps Team"
  privacy     = "closed"
}

# add member to a team
resource "github_team_members" "omac_team_members" {
  team_id  = github_team.omac_team.id

  members {
    username = "kuisathaverat"
    role     = "maintainer"
  }

  members {
    username = "v1v"
    role     = "member"
  }
}

# add repo to a team
resource "github_team_repository" "omac_team_repo" {
  team_id    = github_team.omac_team.id
  repository = github_repository.tf_repo00.name
  permission = "admin"
}

# add owner file to the repository
resource "github_repository_file" "tf_repo00_owner_file" {
  repository = github_repository.tf_repo00.name
  branch = github_branch_default.tf_repo00_default.branch
  file       = ".github/CODEOWNERS"
  content    = "* @omac-team\n.ci/* @kuisathaverat"
  commit_message = "Add CODEOWNERS file"
  overwrite_on_create = true
}

# add webhook to the repository
resource "github_repository_webhook" "tf_repo00_webhook" {
  repository = github_repository.tf_repo00.name
  configuration {
    url = "https://example.com/webhook"
    content_type = "json"
    insecure_ssl = true
  }
  events = [ "push", "pull_request" ]
}

## Secrets management 

# add Vault provider
provider "vault" {
    # token = var.token # or `VAULT_TOKEN`
    # address = "https://104.155.175.88.ip.es.io:8200" # or `VAULT_ADDR`
    skip_child_token = true
}

# read a secret from Vault
data "vault_generic_secret" "foo" {
  path = "secrets/foo"
}

# create a secret in a repository
resource "github_actions_secret" "tf_repo00_example_secret" {
  repository       = github_repository.tf_repo00.name
  secret_name      = "test_secret"
  plaintext_value  = data.vault_generic_secret.foo.data["value"]
}

# create a secret in a repository
resource "github_actions_secret" "tf_repo01_example_secret" {
  repository       = github_repository.tf_repo01.name
  secret_name      = "test_secret"
  plaintext_value  = data.vault_generic_secret.foo.data["value"]
}

# create a secret in a organization
resource "github_actions_organization_secret" "example_secret" {
  secret_name     = "test_secret_org"
  visibility      = "private"
  plaintext_value = data.vault_generic_secret.foo.data["value"]
}

## Manage GitHub Actions

resource "github_actions_organization_permissions" "test" {
  allowed_actions = "selected"
  enabled_repositories = "selected"
  allowed_actions_config {
    github_owned_allowed = true 
    patterns_allowed     = ["actions/cache@*", "actions/checkout@*"]
    verified_allowed     = true
  }
  enabled_repositories_config {
    repository_ids = [github_repository.tf_repo00.repo_id, github_repository.tf_repo01.repo_id]
  }
}
