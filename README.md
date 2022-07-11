# GitHub action PoC
Repository to test the capabilities of GitHub action and how to manage them at scale.

# Secrets

## default GITHUB_TOKEN

An ephemeral GITHUB_TOKEN is is passed to the workflows if none is defined,
it makes easy to access to GitHub repository, 
however you must define the permissions of that GITHUB_TOKEN explicitly
to avoid surprises. By dafault it has only content read permission.
see [Automatic token authentication](https://docs.github.com/en/actions/security-guides/automatic-token-authentication)


# Other links

* [Usage limits](https://docs.github.com/en/actions/learn-github-actions/usage-limits-billing-and-administration#usage-limits)