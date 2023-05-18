# FROM artifacts.developer.gov.bc.ca/docker-remote/php:7.4-fpm
# PHP 8.1 is required for PECL
FROM php:8.1-fpm

# Config arguments
ARG PHP_FPM_PORT=9000
ARG DB_PORT=3306
ARG ENV_FILE=".env"
ARG CRONTAB="FALSE"
ARG DB_HOST="mysql"
ARG DB_HOST_2="mysql"
ARG DB_NAME="moodle"
ARG DB_PASSWORD=""
ARG DB_USER="moodle"

# Moodle App directory
ENV MOODLE_APP_DIR /app/public
ENV CONF_FILE $MOODLE_APP_DIR/config.php
ENV PHP_FPM_DIR /usr/local/etc/php-fpm.d
ENV PHP_INI_FILE $ETC_DIR/php/conf.d/moodlephp.ini

# Version control for Moodle and plugins
ENV MOODLE_BRANCH_VERSION MOODLE_311_STABLE
ENV F2F_BRANCH_VERSION MOODLE_311_STABLE
ENV HVP_BRANCH_VERSION stable
ENV FORMAT_BRANCH_VERSION MOODLE_311
ENV CERTIFICATE_BRANCH_VERSION MOODLE_31_STABLE
ENV CUSTOMCERT_BRANCH_VERSION MOODLE_311_STABLE
ENV DATAFLOWS_BRANCH_VERSION MOODLE_35_STABLE

RUN apt-get update && apt-get install -y git zlib1g-dev libpng-dev libxml2-dev libzip-dev libxslt-dev libldap-dev
RUN pecl install channel://pecl.php.net/xmlrpc-1.0.0RC3
RUN docker-php-ext-enable xmlrpc
RUN docker-php-ext-install pdo pdo_mysql mysqli gd soap intl zip xsl opcache ldap
RUN pecl install -o -f redis
RUN rm -rf /tmp/pear
RUN docker-php-ext-enable redis

COPY ./moodlephp.ini $PHP_INI_FILE
COPY ./moodlephpfpm.conf $PHP_FPM_DIR

RUN git clone --recurse-submodules --jobs 8 --branch $MOODLE_BRANCH_VERSION --single-branch https://github.com/moodle/moodle $MOODLE_APP_DIR

RUN mkdir -p $MOODLE_APP_DIR/admin/tool/trigger && \
    mkdir -p $MOODLE_APP_DIR/admin/tool/dataflows && \
    mkdir -p $MOODLE_APP_DIR/mod/facetoface && \
    mkdir -p $MOODLE_APP_DIR/mod/hvp  && \
    mkdir -p $MOODLE_APP_DIR/course/format/topcoll  && \
    mkdir -p $MOODLE_APP_DIR/mod/certificate  && \
    mkdir -p $MOODLE_APP_DIR/mod/customcert  && \
    chown -R www-data:www-data $MOODLE_APP_DIR/admin/tool/ && \
    chown -R www-data:www-data $MOODLE_APP_DIR/mod/ && \
    chown -R www-data:www-data $MOODLE_APP_DIR/course/format/

RUN git clone --recurse-submodules --jobs 8 https://github.com/catalyst/moodle-tool_trigger $MOODLE_APP_DIR/admin/tool/trigger && \
    git clone --recurse-submodules --jobs 8 --branch $DATAFLOWS_BRANCH_VERSION --single-branch https://github.com/catalyst/moodle-tool_dataflows.git $MOODLE_APP_DIR/admin/tool/dataflows && \
    git clone --recurse-submodules --jobs 8 --branch $F2F_BRANCH_VERSION --single-branch https://github.com/catalyst/moodle-mod_facetoface $MOODLE_APP_DIR/mod/facetoface && \
    git clone --recurse-submodules --jobs 8 --branch $HVP_BRANCH_VERSION --single-branch https://github.com/h5p/moodle-mod_hvp $MOODLE_APP_DIR/mod/hvp && \
    git clone --recurse-submodules --jobs 8 --branch $FORMAT_BRANCH_VERSION --single-branch https://github.com/gjb2048/moodle-format_topcoll $MOODLE_APP_DIR/course/format/topcoll && \
    git clone --recurse-submodules --jobs 8 --branch $CERTIFICATE_BRANCH_VERSION --single-branch https://github.com/mdjnelson/moodle-mod_certificate $MOODLE_APP_DIR/mod/certificate && \
    git clone --recurse-submodules --jobs 8 --branch $CUSTOMCERT_BRANCH_VERSION --single-branch https://github.com/mdjnelson/moodle-mod_customcert $MOODLE_APP_DIR/mod/customcert

# Copy Moodle config
COPY --chown=www-data:www-data ./moodle-config.php $CONF_FILE

# Update config with vars
RUN sed -i "s|DB_PORT|${DB_PORT}|" $CONF_FILE  && \
  sed -i "s|DB_PORT|${DB_PORT}|" $CONF_FILE  && \
  sed -i "s|DB_HOST_2|${DB_HOST_2}|" $CONF_FILE  && \
  sed -i "s|DB_HOST|${DB_HOST}|" $CONF_FILE  && \
  sed -i "s|DB_NAME|${DB_NAME}|" $CONF_FILE  && \
  sed -i "s|DB_USER|${DB_USER}|" $CONF_FILE  && \
  sed -i "s|DB_PASSWORD|${DB_PASSWORD}|" $CONF_FILE  && \
  sed -i "s|MOODLE_APP_DIR|${MOODLE_APP_DIR}|" $CONF_FILE  && \
  sed -i "s|SITE_URL|${SITE_URL}|" $CONF_FILE
