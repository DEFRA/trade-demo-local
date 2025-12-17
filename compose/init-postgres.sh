#!/bin/bash
set -e

# This script runs automatically on first postgres startup (when volume is empty)
# It creates all databases needed by the different services

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE DATABASE "trade-commodity-codes";
    GRANT ALL PRIVILEGES ON DATABASE "trade-commodity-codes" TO $POSTGRES_USER;
EOSQL

echo "Database 'trade-commodity-codes' created successfully"
