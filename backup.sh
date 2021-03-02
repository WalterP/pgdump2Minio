#!/bin/sh

set -e

export PGHOST=${PGHOST:-localhost}
export PGPORT=${PGPORT:-5432}
export PGDATABASE=${PGDATABASE:-test}
export PGUSER=${PGUSER:-test}
export PGDUMP_OPTIONS=${PGDUMP_OPTIONS:-'-Fc -b'}
export PGRESTORE_OPTIONS=${PGRESTORE_OPTIONS:-''}
export PGPASSWORD=${PGPASSWORD:-test}
export VERIFY_BACKUP=${VERIFY_BACKUP:-skip}
export VERIFY_SCHEMA_NAME=${VERIFY_SCHEMA_NAME:-public}
export VERIFY_TABLE_NAME=${VERIFY_TABLE_NAME}
export MINIO_URL=${MINIO_URL:-http://localhost:9000}
export MINIO_ACCESS_KEY=${MINIO_ACCESS_KEY}
export MINIO_SECRET_KEY=${MINIO_SECRET_KEY}

backup_filename=backup-${PGDATABASE}-$(date '+%FT%H-%M-%S-%Z')
restore_db_name="pgdump2minio_backup_verify"

server_alias=dumps3

echo "Configuring connection to Minio server"
mc alias set ${server_alias} ${MINIO_URL} ${MINIO_ACCESS_KEY} ${MINIO_SECRET_KEY}

echo "Dump database to file ${backup_filename}"
pg_dump ${PGDUMP_OPTIONS} > ${backup_filename}




echo "Copying backup to minio storage bucket '${S3_BUCKET}'"
mc cp ${backup_filename} ${server_alias}/${S3_BUCKET}


if [ "${VERIFY_BACKUP}" == "verify" ]; then
    echo "Attempting restore for verification"
    echo "Downloading file from minio"
    mc cp "${server_alias}/${S3_BUCKET}/${backup_filename}" downloaded_backup
    psql -q -c "DROP DATABASE IF EXISTS ${restore_db_name};"
    psql -q -c "CREATE DATABASE ${restore_db_name};"
    echo "Restoring"
    pg_restore ${PGRESTORE_OPTIONS} -d ${restore_db_name} downloaded_backup
    echo "Restore completed"
    if [ -z "${VERIFY_TABLE_NAME}" ]; then
        echo "Table verification skipped."
    else
        echo "Verifying table '${VERIFY_TABLE_NAME}' exists."
        found_table_name=$(psql -q -A -t -c "SELECT '${VERIFY_SCHEMA_NAME}.${VERIFY_TABLE_NAME}'::regclass;" ${restore_db_name})
        if [ "${found_table_name}" != "${VERIFY_TABLE_NAME}" ]; then
            echo "Error: table '${VERIFY_TABLE_NAME}' not found."
            exit 1
        fi
        echo "Success: table '${VERIFY_TABLE_NAME}' exists."
    fi

    echo "Verification passed"
    psql -q -c "DROP DATABASE IF EXISTS ${restore_db_name};"
else
    echo "Verification skipped."
    echo "WARNING: Set 'VERIFY_BACKUP=verify' if you want to attempt a restore. In this case a new DB will be restored. Make sure you have enough space."
fi
