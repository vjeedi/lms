#!/bin/bash

set -e
set -o pipefail

echo "Starting Frappe container initialization..."

BENCH_DIR="/home/frappe/frappe-bench"

if [ -d "$BENCH_DIR/apps/frappe" ]; then
    echo "Bench already exists. Starting..."
    cd "$BENCH_DIR"
    # when running locally, use bench start
    bench start
    # when deploying on a server, use bench serve
    # bench serve --port 8000 --host 0.0.0.0
fi

echo "Bench not found. Creating new bench..."

export PATH="${NVM_DIR}/versions/node/v${NODE_VERSION_DEVELOP}/bin/:${PATH}"

bench init --skip-redis-config-generation frappe-bench
cd frappe-bench

bench set-mariadb-host mariadb
bench set-redis-cache-host redis://redis:6379
bench set-redis-queue-host redis://redis:6379
bench set-redis-socketio-host redis://redis:6379

sed -i '/redis/d' ./Procfile
sed -i '/watch/d' ./Procfile

bench get-app lms

# use site name as defined in SSO
bench new-site "${LMS_SITE_NAME}" \
--force \
--mariadb-root-password "${MARIADB_PASSWORD}" \
--admin-password "${ADMIN_USER_PASSWORD}" \
--no-mariadb-socket


bench --site "${LMS_SITE_NAME}" install-app lms
bench --site "${LMS_SITE_NAME}" set-config developer_mode 1
bench --site "${LMS_SITE_NAME}" clear-cache
bench use "${LMS_SITE_NAME}"

# DNS multitenancy is enabled 
bench config dns_multitenant on

echo "Starting bench..."
bench start
