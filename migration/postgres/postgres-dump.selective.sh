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

echo "Creating schema-only dump for database: $DB_NAME"
# pg_dump \
#     --schema-only \
#     --no-owner \
#     --no-publications \
#     --quote-all-identifiers \
#     --verbose \
#     --host=$DB_HOST \
#     --port=$DB_PORT \
#     --username=$DB_USER \
#     --encoding=$DB_ENCODING \
#     --file "$(pwd)/dumps/$ENV-$DB_NAME-schema-only-${TIMESTAMP}.sql" \
#     $DB_NAME

TABLES="master.service master.client_type master.client_service"
for table in $TABLES; do
  echo "Creating data-only dump for database: $DB_NAME"
  pg_dump \
      --data-only \
      --quote-all-identifiers \
      --verbose \
      --host=$DB_HOST \
      --port=$DB_PORT \
      --username=$DB_USER \
      --encoding=$DB_ENCODING \
      --file "$(pwd)/dumps/$ENV-$DB_NAME-$table-data-only-${TIMESTAMP}.sql" \
      --table $table \
      $DB_NAME
  echo -e "Done. Dumped env ${ENV} ${DB_NAME}-${table} with timestamp: ${TIMESTAMP}"
done

# --no-owner \
# --no-privileges \
# --no-acl \