#!/bin/bash
set -euo pipefail
cd "/home/runner/actions-runner"
sudo ./svc.sh stop
sudo ./svc.sh uninstall "${USER}"
./config.sh remove --token "${TOKEN}"