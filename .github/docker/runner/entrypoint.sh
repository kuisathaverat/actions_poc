#!/bin/bash
set -euo pipefail
./config.sh --url ${REPO_URL} \
    --token ${TOKEN} --ephemeral \
    --labels "self-hosted,Linux,X64,${INSTANCE}" \
    --unattended \
    --disableupdate

./run.sh
