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
    token = var.token # or `GITHUB_TOKEN`
    owner = "kuisatOrg" # or `GITHUB_OWNER`
}

resource "github_repository" "template" {
    name = "template"
    description = "This is my first repository"
    private = true
    is_template = true
    vulnerability_alerts  = true
    license_template  = "Apache-2.0"
    allow_auto_merge  = true
    auto_init = true
    branches = [
        {name = "main", protected = true},
        {name = "dev", protected = true},
        {name = "test", protected = true},
    ]
}

# Create a new repository
resource "github_repository" "tf_repo00" {
    name = "tf-repo00"
    description = "This is my first repository"
    template {
        owner = github_repository.template.owner
        repository = github_repository.template.name
    }
}

resource "github_repository" "tf_repo01" {
    name = "tf-repo01"
    description = "This is my second repository"
    template {
        owner = github_repository.template.owner
        repository = github_repository.template.name
    }
}
