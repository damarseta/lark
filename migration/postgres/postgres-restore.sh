#!/usr/bin/env bash
set -euo pipefail

# Define a timestamp function
timestamp() {
  date +"%s" # current time
}

if [ "$#" -ne 3 ]; then
    echo "Missing argument"
    echo "Usage: $0 <env target> <env source> <timestamp>"
    exit 1
fi

ENV_TARGET="$1"
ENV_SOURCE="$2"
TIMESTAMP="${3}"

#: ensure I dont do something stupid
if [[ "${ENV_TARGET}" == "prod" ]]; then
    echo "No, you can't do that"
    exit 1
fi

if [[ ! -f "vars.${ENV_TARGET}" ]]; then
  echo "File 'vars.${ENV_TARGET}' does not exist."
  echo "Unknown Environment"
  exit 1
else
  # shellcheck source=/dev/null
  source "vars.${ENV_TARGET}"
fi



SCHEMA_ONLY_DUMP="$(pwd)/dumps/${ENV_SOURCE}-$DB_NAME-schema-only-${TIMESTAMP}.sql"
DATA_ONLY_DUMP="$(pwd)/dumps/${ENV_SOURCE}-$DB_NAME-data-only-${TIMESTAMP}.sql"

echo -e "Using environment: ${ENV_TARGET}"
echo -e "Restoring dumps with timestamp: ${TIMESTAMP}"
export PGPASSWORD=$DB_PASSWORD   # hack to make pg_dump does not ask for password interactively.



if [[ "${ENV_TARGET}" == "gcp.prod" ]]; then
    # perform sed to get rid of role asgardsandbox

    echo "Replacing role asgardsandbox with ${DB_USER} on schema dump ..."
    if [[ ! -f "${SCHEMA_ONLY_DUMP}.bak" ]]; then 
      cp "${SCHEMA_ONLY_DUMP}" "${SCHEMA_ONLY_DUMP}.bak"
      sed -i "s/asgardsandbox/${DB_USER}/g" "${SCHEMA_ONLY_DUMP}"
    fi

    echo "Replacing role asgardsandbox with ${DB_USER} on data dump ..."
    if [[ ! -f "${DATA_ONLY_DUMP}.bak" ]]; then
      cp "${DATA_ONLY_DUMP}" "${DATA_ONLY_DUMP}.bak"
      sed -i "s/asgardsandbox/${DB_USER}/g" "${DATA_ONLY_DUMP}"
    fi 

    echo "Ensuring the schema were empty"
    psql \
      --log-file="$(pwd)/logs/restore-${ENV_TARGET}-$DB_NAME-schema-only-${TIMESTAMP}.log" \
      -v ON_ERROR_STOP=1 \
      --echo-errors \
      --host="${DB_HOST}" \
      --port="${DB_PORT}" \
      --username"=${DB_USER}" \
      --dbname="${DB_NAME}" \
      --command="DROP SCHEMA IF EXISTS apiauth_zzz CASCADE";
        
    psql \
        --log-file="$(pwd)/logs/restore-${ENV_TARGET}-$DB_NAME-schema-only-${TIMESTAMP}.log" \
        -v ON_ERROR_STOP=1 \
        --echo-errors \
        --host="${DB_HOST}" \
        --port="${DB_PORT}" \
        --username"=${DB_USER}" \
        --dbname="${DB_NAME}" \
        --command="DROP SCHEMA IF EXISTS apidb_zzz CASCADE";
        
    psql \
        --log-file="$(pwd)/logs/restore-${ENV_TARGET}-$DB_NAME-schema-only-${TIMESTAMP}.log" \
        -v ON_ERROR_STOP=1 \
        --echo-errors \
        --host="${DB_HOST}" \
        --port="${DB_PORT}" \
        --username"=${DB_USER}" \
        --dbname="${DB_NAME}" \
        --command="DROP SCHEMA IF EXISTS assessment CASCADE";
        
    psql \
        --log-file="$(pwd)/logs/restore-${ENV_TARGET}-$DB_NAME-schema-only-${TIMESTAMP}.log" \
        -v ON_ERROR_STOP=1 \
        --echo-errors \
        --host="${DB_HOST}" \
        --port="${DB_PORT}" \
        --username"=${DB_USER}" \
        --dbname="${DB_NAME}" \
        --command="DROP SCHEMA IF EXISTS configs CASCADE";
        
    psql \
        --log-file="$(pwd)/logs/restore-${ENV_TARGET}-$DB_NAME-schema-only-${TIMESTAMP}.log" \
        -v ON_ERROR_STOP=1 \
        --echo-errors \
        --host="${DB_HOST}" \
        --port="${DB_PORT}" \
        --username"=${DB_USER}" \
        --dbname="${DB_NAME}" \
        --command="DROP SCHEMA IF EXISTS content CASCADE";
        
    psql \
        --log-file="$(pwd)/logs/restore-${ENV_TARGET}-$DB_NAME-schema-only-${TIMESTAMP}.log" \
        -v ON_ERROR_STOP=1 \
        --echo-errors \
        --host="${DB_HOST}" \
        --port="${DB_PORT}" \
        --username"=${DB_USER}" \
        --dbname="${DB_NAME}" \
        --command="DROP SCHEMA IF EXISTS identities CASCADE";
        
    psql \
        --log-file="$(pwd)/logs/restore-${ENV_TARGET}-$DB_NAME-schema-only-${TIMESTAMP}.log" \
        -v ON_ERROR_STOP=1 \
        --echo-errors \
        --host="${DB_HOST}" \
        --port="${DB_PORT}" \
        --username"=${DB_USER}" \
        --dbname="${DB_NAME}" \
        --command="DROP SCHEMA IF EXISTS master CASCADE";
        
    psql \
        --log-file="$(pwd)/logs/restore-${ENV_TARGET}-$DB_NAME-schema-only-${TIMESTAMP}.log" \
        -v ON_ERROR_STOP=1 \
        --echo-errors \
        --host="${DB_HOST}" \
        --port="${DB_PORT}" \
        --username"=${DB_USER}" \
        --dbname="${DB_NAME}" \
        --command="DROP SCHEMA IF EXISTS payment CASCADE";
        
    psql \
        --log-file="$(pwd)/logs/restore-${ENV_TARGET}-$DB_NAME-schema-only-${TIMESTAMP}.log" \
        -v ON_ERROR_STOP=1 \
        --echo-errors \
        --host="${DB_HOST}" \
        --port="${DB_PORT}" \
        --username"=${DB_USER}" \
        --dbname="${DB_NAME}" \
        --command="DROP SCHEMA IF EXISTS public CASCADE";
        
    psql \
        --log-file="$(pwd)/logs/restore-${ENV_TARGET}-$DB_NAME-schema-only-${TIMESTAMP}.log" \
        -v ON_ERROR_STOP=1 \
        --echo-errors \
        --host="${DB_HOST}" \
        --port="${DB_PORT}" \
        --username"=${DB_USER}" \
        --dbname="${DB_NAME}" \
        --command="DROP PUBLICATION IF EXISTS pub_tipedana CASCADE";
        

    psql \
        --log-file="$(pwd)/logs/restore-${ENV_TARGET}-$DB_NAME-schema-only-${TIMESTAMP}.log" \
        -v ON_ERROR_STOP=1 \
        --echo-errors \
        --host="${DB_HOST}" \
        --port="${DB_PORT}" \
        --username"=${DB_USER}" \
        --dbname="${DB_NAME}" \
        --command="create schema public";
        
fi


echo "Restoring schema-only dump for database: $DB_NAME with timestamp: ${TIMESTAMP}"
psql \
    --log-file="$(pwd)/logs/restore-${ENV_TARGET}-$DB_NAME-schema-only-${TIMESTAMP}.log" \
    -v ON_ERROR_STOP=1 \
    --echo-errors \
    --host="${DB_HOST}" \
    --port="${DB_PORT}" \
    --username"=${DB_USER}" \
    --dbname="${DB_NAME}" \
    --file ${SCHEMA_ONLY_DUMP}

echo "Restoring data-only dump for database: $DB_NAME with timestamp: ${TIMESTAMP}"
psql \
    --log-file="$(pwd)/logs/restore-${ENV_TARGET}-$DB_NAME-data-only-${TIMESTAMP}.log" \
    -v ON_ERROR_STOP=1 \
    --echo-errors \
    --host="${DB_HOST}" \
    --port="${DB_PORT}" \
    --username"=${DB_USER}" \
    --dbname="${DB_NAME}" \
    --file "$(pwd)/dumps/${ENV_SOURCE}-$DB_NAME-data-only-${TIMESTAMP}.sql"

# 1648613275