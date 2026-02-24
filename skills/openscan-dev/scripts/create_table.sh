#!/bin/bash
# Helper script to create tables in Docker PostgreSQL
# Usage: ./create_table.sh <sql_file>
# Example: ./create_table.sh /tmp/my_migration.sql

SQL_FILE="${1:-/dev/stdin}"

docker exec -i openscan-postgres psql -U openscan -d openscan < "$SQL_FILE"
echo "Done."
