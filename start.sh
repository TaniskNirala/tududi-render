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

# Set up automatic backup every 30 minutes
echo "*/30 * * * * rclone copy /tududi_db/production.sqlite3 gdrive:app-backups/ --config /root/.config/rclone/rclone.conf" \
  > /etc/crontabs/root

# Start cron in background (Alpine uses crond)
crond -b
echo "Auto-backup every 30 minutes started"

echo "========================================="
echo "   Starting Tududi on port 3002"
echo "========================================="

cd /app
echo "PATH=$PATH"
which bundle || true
which ruby || true
find / -name bundle 2>/dev/null | head
# sleep 300

echo "=== PROCESS INFO ==="
find / -maxdepth 3 -type f 2>/dev/null | grep -Ei "tududi|app|server|start"

echo "=== ROOT ==="
ls -lah /

echo "=== APP ==="
ls -lah /app 2>/dev/null || true

echo "=== BIN ==="
ls -lah /usr/local/bin

sleep 600
