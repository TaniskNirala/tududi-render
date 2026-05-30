#!/bin/bash
set -e

echo "=== Tududi Starting ==="

# Create rclone config directory
mkdir -p /root/.config/rclone

# Write rclone config from environment variable
echo "$RCLONE_CONF" > /root/.config/rclone/rclone.conf

echo "Restoring Tududi database from Google Drive..."
mkdir -p /app/backend/db
rclone copy gdrive:app-backups/tududi.db /app/backend/db/ 2>/dev/null \
  && echo "Database restored successfully" \
  || echo "No existing backup — starting fresh"

# Back up every 30 minutes
echo "*/30 * * * * root rclone copy /app/backend/db/tududi.db \
  gdrive:app-backups/ --config /root/.config/rclone/rclone.conf \
  >> /var/log/backup.log 2>&1" \
  > /etc/cron.d/tududi-backup

chmod 644 /etc/cron.d/tududi-backup
service crond start
echo "Backup cron started"

echo "Starting Tududi..."
exec /usr/local/bin/tududi-start 2>/dev/null \
  || exec bundle exec ruby app.rb -o 0.0.0.0 -p 3002 2>/dev/null \
  || exec sh /docker-entrypoint.sh
