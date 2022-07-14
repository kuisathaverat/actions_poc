#!/bin/sh
set -eu

PAT=${1:?-"Missing Personal Access Token"}
REPO=${2:?-"Missing Repository"}
GITHUB_ENV=${GITHUB_ENV:?-"Missing GitHub Environment"}

GITHUB_RUNNER_TOKEN=$(curl -sS \
    -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: token ${PAT}" \
    https://api.github.com/repos/${REPO}/actions/runners/registration-token |jq -r .token)
echo "GITHUB_RUNNER_TOKEN=${GITHUB_RUNNER_TOKEN}" >> $GITHUB_ENV
echo "::add-mask::${GITHUB_RUNNER_TOKEN}"
echo "::set-output name=token::${GITHUB_RUNNER_TOKEN}"