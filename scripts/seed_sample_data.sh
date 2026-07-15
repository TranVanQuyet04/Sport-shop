#!/usr/bin/env bash
# ==============================================================================
# SCRIPT: seed_sample_data.sh
# DESCRIPTION: Automates seeding sample data into all 4 SportSwearShop databases
# USAGE: ./scripts/seed_sample_data.sh [-c CONTAINER_NAME] [-u USERNAME] [-p PASSWORD] [-l]
# ==============================================================================

CONTAINER_NAME="sport-swear-shop-postgres"
USERNAME="postgres"
PASSWORD="CHANGE_ME_DATABASE_PASSWORD"
LOCAL_MODE=false

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -c|--container) CONTAINER_NAME="$2"; shift ;;
        -u|--user) USERNAME="$2"; shift ;;
        -p|--password) PASSWORD="$2"; shift ;;
        -l|--local) LOCAL_MODE=true ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

echo "=============================================================================="
echo " SPORT SWEAR SHOP - AUTOMATING DATABASE SAMPLE DATA SEEDING"
echo "=============================================================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SAMPLE_DATA_DIR="${PROJECT_ROOT}/backend/sample_data"

if [ ! -d "$SAMPLE_DATA_DIR" ]; then
    echo "ERROR: Could not find sample_data directory at: $SAMPLE_DATA_DIR"
    exit 1
fi

DATABASES=("auth_db:01_auth_db.sql" "product_catalog_db:02_product_catalog_db.sql" "order_fulfillment_db:03_order_fulfillment_db.sql" "support_chat_db:04_support_chat_db.sql")

if [ "$LOCAL_MODE" = true ]; then
    echo "[INFO] Mode: Local PostgreSQL Server ($USERNAME)"
    export PGPASSWORD="$PASSWORD"
    for item in "${DATABASES[@]}"; do
        DB_NAME="${item%%:*}"
        FILE_NAME="${item##*:}"
        FILE_PATH="${SAMPLE_DATA_DIR}/${FILE_NAME}"
        printf "Seeding database '%s' from %s... " "$DB_NAME" "$FILE_NAME"
        if psql -U "$USERNAME" -d "$DB_NAME" -f "$FILE_PATH" > /dev/null 2>&1; then
            echo "[SUCCESS]"
        else
            echo "[FAILED]"
        fi
    done
else
    echo "[INFO] Mode: Docker Container ('$CONTAINER_NAME')"
    if ! docker ps --filter "name=${CONTAINER_NAME}" --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
        echo "ERROR: Docker container '${CONTAINER_NAME}' is not running!"
        echo "Please start your containers first using 'docker-compose up -d'"
        exit 1
    fi

    for item in "${DATABASES[@]}"; do
        DB_NAME="${item%%:*}"
        FILE_NAME="${item##*:}"
        FILE_PATH="${SAMPLE_DATA_DIR}/${FILE_NAME}"
        printf "Seeding database '%s' from %s... " "$DB_NAME" "$FILE_NAME"
        if cat "$FILE_PATH" | docker exec -i "$CONTAINER_NAME" psql -U "$USERNAME" -d "$DB_NAME" > /dev/null 2>&1; then
            echo "[SUCCESS]"
        else
            echo "[FAILED]"
        fi
    done
fi

echo "=============================================================================="
echo " All database seeding operations completed!"
echo "=============================================================================="
