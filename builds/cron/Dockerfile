# artifacts.developer.gov.bc.ca/docker-remote/php:7.4-fpm
ARG CRON_IMAGE=php:8.0-fpm

FROM $CRON_IMAGE

RUN apt-get update
RUN apt-get install -y mariadb-client-10.5 cron supervisor zlib1g-dev libpng-dev libxml2-dev libzip-dev libxslt-dev libldap-dev
RUN pecl install channel://pecl.php.net/xmlrpc-1.0.0RC3
RUN docker-php-ext-enable xmlrpc
RUN docker-php-ext-install pdo pdo_mysql mysqli gd soap intl zip xsl opcache ldap

RUN pecl install -o -f redis
RUN rm -rf /tmp/pear
RUN docker-php-ext-enable redis
RUN apt-get update

ARG ETC_DIR=/usr/local/etc

ENV DOCKER_CONTEXT ./builds/cron
ENV PHP_FPM_DIR $ETC_DIR/php-fpm.d
ENV PHP_FPM_CONF_FILE $PHP_FPM_DIR/php-fpm.conf
ENV PHP_INI_DIR $ETC_DIR/php/conf.d
# ENV PHP_INI_DIR $ETC_DIR/php
ENV PHP_INI_FILE $PHP_INI_DIR/php.ini
ENV CRON_LOG /var/log/moodle-cron.log

# RUN chown -R www-data:www-data $PHP_INI_DIR
# RUN chown -R www-data:www-data $PHP_FPM_DIR

# RUN apt-get install -y mariadb-client-10.5 cron supervisor zlib1g-dev libpng-dev libxml2-dev libzip-dev libxslt-dev libldap-dev


#
#
#
#



# Copy config files
RUN touch $PHP_INI_FILE
# RUN mkdir -p $PHP_FPM_DIR
COPY $DOCKER_CONTEXT/php.ini $PHP_INI_FILE
COPY $DOCKER_CONTEXT/php-fpm.conf $PHP_FPM_CONF_FILE
# RUN chmod 0644 /etc/cron.d/moodle-cron

# Copy hello-cron file to the cron.d directory
COPY $DOCKER_CONTEXT/crontab.txt /etc/cron.d/moodle-cron
# Apply cron job
RUN crontab /etc/cron.d/moodle-cron
# Create cron log file
RUN touch $CRON_LOG
# Give execution rights on the cron job
RUN chmod 0644 $CRON_LOG

# Run cron
CMD cron && tail -f $CRON_LOG
