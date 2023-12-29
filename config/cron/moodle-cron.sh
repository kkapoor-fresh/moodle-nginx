#!/bin/bash
while true; do
  /usr/local/bin/php /app/public/admin/cli/cron.php >&1
  sleep 60
done
