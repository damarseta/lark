#!/usr/bin/env bash
# this script will remove all dangling images
# copyleft 2020 - widnyana <wid@widnyana.web.id>

set -euo pipefail

log () {
    echo $(date +"%Y-%m-%d %H:%M:%S") $@
}

log "[+] Begin deleting dangling images"
IMAGES=$(docker image ls --filter "dangling=true" --format "{{.ID}}")


if [[ "${IMAGES//[$'\t\r\n']}" == "" ]]; then
    log "[+] No dangling image to delete"
else
    log "[+] Deleting dangling image(s)"
    docker rmi -f ${IMAGES}
fi

log "[+] Done"

log "=================================="
echo ""

