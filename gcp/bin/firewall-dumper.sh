#!/usr/bin/env bash
set -euo pipefail

# This script will dump all firewall inside given PROJECT_ID if specified,
# or, dump firewalls from all accessible projects if PROJECT_ID is not specified.
# Usage:
#     bash ${0} [PROJECT_ID]
# Example:
#     bash firewall-dumper.sh gcp-project-112233 <ENTER>
#     bash firewall-dumper.sh <ENTER>
# 
# XDG_CONFIG_HOME usually points to ${HOME}/.config
# see: https://wiki.archlinux.org/index.php/XDG_Base_Directory
# 
# (wtfpl) 2024 - widnyana


OUT_PATH="$(pwd)/out"
GOOGLE_APPLICATION_CREDENTIALS="${XDG_CONFIG_HOME}/gcloud/application_default_credentials.json"

PROJECTID=${1:-none}
if [[ ${PROJECTID} == "none" ]]; then
    echo "ProjectID not specified. Fetching all project ID(s)..."
    PROJECTID=$(gcloud projects list --format="value(project_id)" | sort | uniq | grep -v "sys-")
fi

mkdir -p "${OUT_PATH}"

for PROJECT in $PROJECTID
do
  FW_FILE_NAME="${OUT_PATH}/fw.${PROJECT}.json"
  if [[ -f $FW_FILE_NAME ]]; then
    echo -e "File ${FW_FILE_NAME} already exists. Skipping..."
    continue
  fi
  
  echo "[+] Project Name: ${PROJECT}"
  if [[ $(gcloud services list --project="${PROJECT}" --format="table(NAME)" | sed '1d') =~ "compute.googleapis.com" ]];then
      echo -e "[>] Firewall rules:\n"
      gcloud compute firewall-rules list --project="${PROJECT}" --format="json" --quiet > $FW_FILE_NAME
  
  else
      echo "[!] No Firewall rules found"
  fi

  echo -e "================================================================================================\n\n"
done