#!/usr/bin/env bash
# delete local docker images which contains "local-build" tag
# copyleft 2020 - widnyana <wid@widnyana.web.id>

set -euo pipefail

log () {
    echo $(date +"%Y-%m-%d %H:%M:%S") $@
}

log "[+] Begin deleting untagged images"
IMAGES="$(docker images | grep none | awk '{ print $3; }')"


if [[ "${IMAGES}" == '' ]]; then
    log "[+] No untagged image to delete"
else
    log "[+] Deleting image(s) without tag"
    docker rmi -f ${IMAGES} && echo "done" || echo "failed"
fi

log "[+] Done"

log "[+] Begin deleting local-build images"
IMAGES=$(docker images | grep "local-build" | awk '{ print $3; }')


if [[ "${IMAGES}" == "" ]]; then
    log "[+] No local-build image to delete"
else
    log "[+] Deleting image(s) with local-build tag"
    docker rmi -f ${IMAGES}  && echo "done" || echo "failed"
fi

log "[+] Done"


log "=================================="
echo ""

