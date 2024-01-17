#!/usr/bin/env bash
# perform clean-up on gitlab-runner
# copyleft 2020 - widnyana <wid@widnyana.web.id>

set -euo pipefail

log () {
    echo $(date +"%Y-%m-%d %H:%M:%S") $@
}

log "[+] Begin performing cleanup for gitlab-runner"

rm -fr ~gitlab-runner/.cache/golangci-lint/*

log "[+] Done"
log "=================================="
echo ""

