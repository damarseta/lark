#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
    echo "Missing argument"
    exit 1
fi

# Define a timestamp function
timestamp() {
  date +"%s" # current time
}

ENV="$1"
if [[ ! -f "vars.${ENV}" ]]; then
  echo "File 'vars.${ENV}' does not exist."
  echo "Unknown Environment"
  exit 1
else
  source vars.${ENV}
fi

TIMESTAMP=$(timestamp)
echo -e "Using environment: $ENV"
export PGPASSWORD=$DB_PASSWORD   # hack to make pg_dump does not ask for password interactively.


pg_dumpall --roles-only \
    --verbose \
    --host=$DB_HOST \
    --port=$DB_PORT \
    --username=$DB_USER \
    --database $DB_NAME \
    --file "$ENV-$DB_NAME-roles-only-${TIMESTAMP}.sql" \
    