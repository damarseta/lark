#!/usr/bin/env bash
set -e

REMOVE_OLDER_THAN="720h"


log () {
    echo $(date +"%Y-%m-%d %H:%M:%S") $@
}

log "[+] Removing docker image(s) older than ${REMOVE_OLDER_THAN}"
/usr/bin/docker image prune -a --force --filter "until=${REMOVE_OLDER_THAN}"
log "[+] Done"


log "=================================="
echo ""

