# FROM artifacts.developer.gov.bc.ca/docker-remote/php:7.4-fpm
FROM php:7.4-fpm

RUN apt-get update && apt-get install -y cron supervisor zlib1g-dev libpng-dev libxml2-dev libzip-dev libxslt-dev
RUN docker-php-ext-install pdo pdo_mysql mysqli gd xmlrpc soap intl zip xsl opcache
RUN pecl install -o -f redis &&  rm -rf /tmp/pear &&  docker-php-ext-enable redis

RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

COPY ./builds/php/moodlephp.ini "$PHP_INI_DIR/conf.d/moodlephp.ini"
COPY ./builds/php/moodlephpfpm.conf "/usr/local/etc/php-fpm.d"

# Create cron log file
RUN touch /var/log/schedule.log
RUN chmod 0777 /var/log/schedule.log

# Setup and run cron
RUN (crontab -l -u root; echo "* * * * * su -c '/usr/local/bin/php /var/www/html/admin/cli/cron.php >&1'") | crontab
