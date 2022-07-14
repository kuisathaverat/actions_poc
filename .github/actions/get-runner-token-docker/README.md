# Get Runner Token docker action

Request a new Runner token to associate a new Runner to GitHub Actions.
The token is masked from logs.

## Inputs

## `pat`

**Required** Personal Access Token to make the request, it requires repo:admin or org:admin permissions.

## `reposiroty`

**Required** Owner/repository where we going to request the Runner token.

## Outputs

## `token`

The new Runner token.

## Example usage

- uses: ./.github/actions/get-runner-token-docker/
  with:
    pat: ${{ secrets.PAT }}
    reposiroty: ${{ github.repository }}