ARG DOCKER_FROM_IMAGE=php:7.4-fpm

FROM $DOCKER_FROM_IMAGE

# Environment uses ONLY production or development
ARG PHP_INI_ENVIRONMENT=production

# Moodle App directory
ENV MOODLE_APP_DIR /app/public
ENV PHP_INI_DIR /usr/local/etc/php
ENV PHP_INI_FILE $PHP_INI_DIR/php.ini

# RUN docker-php-ext-install pdo pdo_mysql mysqli gd xmlrpc soap intl zip xsl opcache
# RUN docker-php-ext-install pdo mysqli gd xmlrpc soap intl zip xsl opcache
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions && \
    install-php-extensions pdo pdo_mysql mysqli gd soap intl zip xsl opcache ldap

RUN apt-get update && apt-get install -y cron supervisor zlib1g-dev libpng-dev libxml2-dev libzip-dev libxslt-dev wget libfcgi-bin

RUN pecl install -o -f redis &&  rm -rf /tmp/pear &&  docker-php-ext-enable redis

# Add healthcheck
RUN wget -O /usr/local/bin/php-fpm-healthcheck \
    https://raw.githubusercontent.com/renatomefi/php-fpm-healthcheck/master/php-fpm-healthcheck \
    && chmod +x /usr/local/bin/php-fpm-healthcheck
COPY ./php-fpm-healthcheck.sh /usr/local/bin/

RUN mv "$PHP_INI_DIR/php.ini-$PHP_INI_ENVIRONMENT" "$PHP_INI_FILE"
COPY ./config/php/php.ini "$PHP_INI_DIR/moodlephp.ini"
COPY ./config/php/php-fpm.conf "/usr/local/etc/php-fpm.d"

# Create cron log file
RUN touch /var/log/schedule.log
RUN chmod 0777 /var/log/schedule.log

# Setup and run cron
RUN (crontab -l -u root; echo "* * * * * su -c '/usr/local/bin/php /app/public/admin/cli/cron.php >&1'") | crontab
