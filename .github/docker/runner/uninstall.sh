#!/bin/bash
set -euo pipefail
cd "/home/runner/actions-runner"
./config.sh remove --token "${TOKEN}"