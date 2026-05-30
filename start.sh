#!/bin/sh
set -e

echo "========================================="
echo "   Tududi Starting"
echo "========================================="

# Create rclone config from environment variable
mkdir -p /root/.config/rclone
echo "$RCLONE_CONF" > /root/.config/rclone/rclone.conf
echo "rclone configured"

# Make sure the database folder exists
mkdir -p /tududi_db

# Download database from Google Drive
echo "Restoring Tududi database from Google Drive..."
rclone copy gdrive:app-backups/production.sqlite3 /tududi_db/ \
  && echo "Database restored from Google Drive" \
  || echo "No existing backup - starting fresh"

mkdir -p /app/backend/db

if [ -f /tududi_db/production.sqlite3 ]; then
    cp /tududi_db/production.sqlite3 /app/backend/db/production.sqlite3
    echo "Database copied into Tududi data directory"
fi

# Set up automatic backup every 30 minutes
echo "*/30 * * * * rclone copy /tududi_db/production.sqlite3 gdrive:app-backups/ --config /root/.config/rclone/rclone.conf" \
  > /etc/crontabs/root

# Start cron in background (Alpine uses crond)
crond -b
echo "Auto-backup every 30 minutes started"

echo "========================================="
echo "   Starting Tududi on port 3002"
echo "========================================="

echo "Searching for sqlite databases..."
find /app -name "*.sqlite3" -o -name "*.db" 2>/dev/null
