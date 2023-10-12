ARG DOCKER_FROM_IMAGE=php:8.0-fpm

FROM $DOCKER_FROM_IMAGE

ARG PHP_INI_ENVIRONMENT=production
ARG MOODLE_BRANCH_VERSION=MOODLE_311_STABLE
ARG F2F_BRANCH_VERSION=MOODLE_400_STABLE
ARG HVP_BRANCH_VERSION=stable
ARG FORMAT_BRANCH_VERSION=MOODLE_311
ARG CERTIFICATE_BRANCH_VERSION=MOODLE_31_STABLE
ARG CUSTOMCERT_BRANCH_VERSION=MOODLE_311_STABLE
ARG DATAFLOWS_BRANCH_VERSION=MOODLE_35_STABLE

# Moodle App directory
ENV MOODLE_APP_DIR /app/public
ENV ETC_DIR=/usr/local/etc
ENV PHP_INI_DIR $ETC_DIR/php
ENV PHP_INI_FILE /php.ini

RUN echo "Building Moodle version: $MOODLE_BRANCH_VERSION for $PHP_INI_ENVIRONMENT environment"

RUN apt-get update && apt-get install -y \
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
  && apt-get clean

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
  ldap
# ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
# RUN chmod +x /usr/local/bin/install-php-extensions && \
#     install-php-extensions pdo pdo_mysql mysqli gd soap intl zip xsl opcache ldap
RUN pecl install channel://pecl.php.net/xmlrpc-1.0.0RC3 xmlrpc
RUN docker-php-ext-enable xmlrpc

# Add healthcheck
RUN wget -O /usr/local/bin/php-fpm-healthcheck \
    https://raw.githubusercontent.com/renatomefi/php-fpm-healthcheck/master/php-fpm-healthcheck \
    && chmod +x /usr/local/bin/php-fpm-healthcheck
# Update healthcheck
RUN wget -O $(which php-fpm-healthcheck) \
    https://raw.githubusercontent.com/renatomefi/php-fpm-healthcheck/master/php-fpm-healthcheck \
    && chmod +x $(which php-fpm-healthcheck)

RUN pecl install -o -f redis
RUN rm -rf /tmp/pear
RUN docker-php-ext-enable redis

RUN git clone --recurse-submodules --jobs 8 --branch $MOODLE_BRANCH_VERSION --single-branch https://github.com/moodle/moodle $MOODLE_APP_DIR

RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_FILE"
COPY ./config/php/php.ini "$PHP_INI_DIR/conf.d/moodlephp.ini"
COPY ./config/php/php-fpm.conf "/usr/local/etc/php-fpm.d"
COPY ./config/moodle/config.php "/app/public/config.php"

RUN mkdir -p $MOODLE_APP_DIR/admin/tool/trigger && \
    mkdir -p $MOODLE_APP_DIR/admin/tool/dataflows && \
    mkdir -p $MOODLE_APP_DIR/mod/facetoface && \
    mkdir -p $MOODLE_APP_DIR/mod/hvp  && \
    mkdir -p $MOODLE_APP_DIR/course/format/topcoll  && \
    mkdir -p $MOODLE_APP_DIR/mod/certificate  && \
    mkdir -p $MOODLE_APP_DIR/mod/customcert  && \
    chown -R www-data:www-data $MOODLE_APP_DIR

RUN git clone --recurse-submodules --jobs 8 https://github.com/catalyst/moodle-tool_trigger $MOODLE_APP_DIR/admin/tool/trigger && \
    git clone --recurse-submodules --jobs 8 --branch $DATAFLOWS_BRANCH_VERSION --single-branch https://github.com/catalyst/moodle-tool_dataflows.git $MOODLE_APP_DIR/admin/tool/dataflows && \
    git clone --recurse-submodules --jobs 8 --branch $F2F_BRANCH_VERSION --single-branch https://github.com/catalyst/moodle-mod_facetoface $MOODLE_APP_DIR/mod/facetoface && \
    git clone --recurse-submodules --jobs 8 --branch $HVP_BRANCH_VERSION --single-branch https://github.com/h5p/moodle-mod_hvp $MOODLE_APP_DIR/mod/hvp && \
    git clone --recurse-submodules --jobs 8 --branch $FORMAT_BRANCH_VERSION --single-branch https://github.com/gjb2048/moodle-format_topcoll $MOODLE_APP_DIR/course/format/topcoll && \
    git clone --recurse-submodules --jobs 8 --branch $CERTIFICATE_BRANCH_VERSION --single-branch https://github.com/mdjnelson/moodle-mod_certificate $MOODLE_APP_DIR/mod/certificate && \
    git clone --recurse-submodules --jobs 8 --branch $CUSTOMCERT_BRANCH_VERSION --single-branch https://github.com/mdjnelson/moodle-mod_customcert $MOODLE_APP_DIR/mod/customcert
