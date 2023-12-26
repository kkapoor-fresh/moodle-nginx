stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0

# echo "Delete Moodle config..."

# rm -f /var/www/html/config.php
echo "Deleting shared Moodle files..."
rm -rf /var/www/html/*
# echo "Move Moodle web files to /tmp/old..."
# mv /var/www/html/* /tmp/old
# mkdir /var/www/html

echo "Replace Moodle index with maintenance page..."
cp /tmp/moodle_index_during_maintenance.php /var/www/html/index.php

echo "Copying files..."
cp /app/public/* /var/www/html -p -r

# echo "Delete [/tmp/old] Moodle web files..."
# rm -rf /var/www/html/*
# mv /var/www/html /var/www/html_old
# mkdir /var/www/html
# rsync -a --delete empty/ /tmp/old
