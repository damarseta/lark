#!/usr/bin/env bash
# this script will remove all dangling images
# copyleft 2020 - widnyana <wid@widnyana.web.id>

set -euo pipefail

log () {
    echo $(date +"%Y-%m-%d %H:%M:%S") $@
}

log "[+] Begin deleting dangling images"
IMAGES=$(docker image ls --filter "dangling=true" --format "{{.ID}}")


echo $IMAGES


if [[ "${IMAGES}" -eq "" ]]; then
    log "[+] No dangling image to delete"
fi

log "[+] Done"

log "=================================="
echo ""

