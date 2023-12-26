# ARG DOCKER_FROM_IMAGE=php:8.0-fpm
FROM php:8.3.0-fpm

ARG PHP_INI_ENVIRONMENT=production
# Version control for Moodle and plugins
ENV MOODLE_BRANCH_VERSION MOODLE_403_STABLE
ENV F2F_BRANCH_VERSION MOODLE_400_STABLE
ENV HVP_BRANCH_VERSION stable
ENV FORMAT_BRANCH_VERSION MOODLE_402
# ENV CERTIFICATE_BRANCH_VERSION MOODLE_31_STABLE
ENV CUSTOMCERT_BRANCH_VERSION MOODLE_402_STABLE
ENV DATAFLOWS_BRANCH_VERSION MOODLE_35_STABLE

# Moodle App directory
ENV MOODLE_APP_DIR /app/public
ENV ETC_DIR=/usr/local/etc
ENV PHP_INI_DIR $ETC_DIR/php
ENV PHP_INI_FILE $ETC_DIR/php/conf.d/moodle-php.ini

RUN echo "Building Moodle version: $MOODLE_BRANCH_VERSION for $PHP_INI_ENVIRONMENT environment"

RUN apt-get update && apt-get install --no-install-recommends -y \
    git \
    zlib1g-dev \
    libpng-dev \
    libxml2-dev \
    libzip-dev \
    libxslt-dev \
    libldap-dev \
    libfreetype-dev \
    wget \
    libfcgi-bin \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*


RUN docker-php-ext-install \
    pdo \
    pdo_mysql \
    mysqli \
    gd \
    soap \
    intl \
    zip \
    xsl \
    opcache \
    ldap \
  && pecl install channel://pecl.php.net/xmlrpc-1.0.0RC3 xmlrpc \
  && docker-php-ext-enable xmlrpc \
  && wget -O /usr/local/bin/php-fpm-healthcheck \
    https://raw.githubusercontent.com/renatomefi/php-fpm-healthcheck/master/php-fpm-healthcheck \
  && chmod +x /usr/local/bin/php-fpm-healthcheck \
  && wget -O $(which php-fpm-healthcheck) \
    https://raw.githubusercontent.com/renatomefi/php-fpm-healthcheck/master/php-fpm-healthcheck \
  && chmod +x $(which php-fpm-healthcheck) \
  && pecl install -o -f redis xdebug \
  && rm -rf /tmp/pear \
  && docker-php-ext-enable redis xdebug \
  && git clone --recurse-submodules --jobs 8 --branch $MOODLE_BRANCH_VERSION --single-branch https://github.com/moodle/moodle $MOODLE_APP_DIR

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_FILE"
COPY ./config/php/php.ini "$PHP_INI_DIR/conf.d/moodle-php.ini"
# COPY ./config/php/php-fpm.conf "$ETC_DIR/php-fpm.d/moodle.conf"
COPY ./config/moodle/config.php "$MOODLE_APP_DIR/config.php"
RUN mkdir $MOODLE_APP_DIR/info
COPY ./config/php/info.php "$MOODLE_APP_DIR/info/info.php"

# Add PHP config check
COPY ./config/php/phpconfigcheck.php "$MOODLE_APP_DIR/info/phpconfigcheck.php"

RUN mkdir -p $MOODLE_APP_DIR/admin/tool/trigger && \
    mkdir -p $MOODLE_APP_DIR/admin/tool/dataflows && \
    mkdir -p $MOODLE_APP_DIR/mod/facetoface && \
    mkdir -p $MOODLE_APP_DIR/mod/hvp  && \
    mkdir -p $MOODLE_APP_DIR/course/format/topcoll  && \
#    mkdir -p $MOODLE_APP_DIR/mod/certificate  && \
#    mkdir -p $MOODLE_APP_DIR/mod/customcert  && \
    chown -R www-data:www-data $MOODLE_APP_DIR

RUN git clone --recurse-submodules --jobs 8 https://github.com/catalyst/moodle-tool_trigger $MOODLE_APP_DIR/admin/tool/trigger && \
    git clone --recurse-submodules --jobs 8 --branch $DATAFLOWS_BRANCH_VERSION --single-branch https://github.com/catalyst/moodle-tool_dataflows.git $MOODLE_APP_DIR/admin/tool/dataflows && \
    git clone --recurse-submodules --jobs 8 --branch $F2F_BRANCH_VERSION --single-branch https://github.com/catalyst/moodle-mod_facetoface $MOODLE_APP_DIR/mod/facetoface && \
    git clone --recurse-submodules --jobs 8 --branch $HVP_BRANCH_VERSION --single-branch https://github.com/h5p/moodle-mod_hvp $MOODLE_APP_DIR/mod/hvp && \
    git clone --recurse-submodules --jobs 8 --branch $FORMAT_BRANCH_VERSION --single-branch https://github.com/gjb2048/moodle-format_topcoll $MOODLE_APP_DIR/course/format/topcoll && \
    git clone --recurse-submodules --jobs 8 --branch $CUSTOMCERT_BRANCH_VERSION --single-branch https://github.com/mdjnelson/moodle-mod_customcert $MOODLE_APP_DIR/mod/customcert
#    git clone --recurse-submodules --jobs 8 --branch $CERTIFICATE_BRANCH_VERSION --single-branch https://github.com/mdjnelson/moodle-mod_certificate $MOODLE_APP_DIR/mod/certificate && \
