ARG PHP_IMAGE=php:8.0-fpm

FROM $PHP_IMAGE

# Config arguments
ARG DB_PORT=3306
ARG DB_HOST=${DB_HOST}
ARG DB_NAME=${DB_NAME}
ARG DB_PASSWORD=${DB_PASSWORD}
ARG DB_USER=${DB_USER}
ARG ETC_DIR=/usr/local/etc

# Moodle App directory
ENV MOODLE_APP_DIR /app/public
ENV PHP_INI_DIR $ETC_DIR/php/conf.d
ENV PHP_INI_FILE $PHP_INI_DIR/php.ini

# Version control for Moodle and plugins
ENV MOODLE_BRANCH_VERSION MOODLE_311_STABLE
ENV F2F_BRANCH_VERSION MOODLE_311_STABLE
ENV HVP_BRANCH_VERSION stable
ENV FORMAT_BRANCH_VERSION MOODLE_311
ENV CERTIFICATE_BRANCH_VERSION MOODLE_31_STABLE
ENV CUSTOMCERT_BRANCH_VERSION MOODLE_311_STABLE
ENV DATAFLOWS_BRANCH_VERSION MOODLE_35_STABLE

RUN apt-get update && apt-get install -y git zlib1g-dev libpng-dev libxml2-dev libzip-dev libxslt-dev libldap-dev wget libfcgi-bin

# Add healthcheck
RUN wget -O /usr/local/bin/php-fpm-healthcheck \
    https://raw.githubusercontent.com/renatomefi/php-fpm-healthcheck/master/php-fpm-healthcheck \
    && chmod +x /usr/local/bin/php-fpm-healthcheck
COPY ./php-fpm-healthcheck.sh /usr/local/bin/

RUN pecl install channel://pecl.php.net/xmlrpc-1.0.0RC3
RUN docker-php-ext-enable xmlrpc
RUN docker-php-ext-install pdo pdo_mysql mysqli gd soap intl zip xsl opcache ldap
RUN pecl install -o -f redis
RUN rm -rf /tmp/pear
RUN docker-php-ext-enable redis

RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

COPY ./config/php/php.ini "$PHP_INI_DIR/moodlephp.ini"
COPY ./config/php/php-fpm.conf "/usr/local/etc/php-fpm.d"

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
