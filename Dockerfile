FROM composer:2.10 AS build

RUN curl -fsSL -o /tmp/moodle.tgz https://download.moodle.org/download.php/direct/stable503/moodle-5.3.tgz && \
  mkdir -p /var/www/moodle && \
  tar -xzf /tmp/moodle.tgz -C /var/www/moodle --strip-components=1 && \
  rm /tmp/moodle.tgz && \
  cd /var/www/moodle && \
  composer install --no-dev --classmap-authoritative --ignore-platform-reqs

COPY config.php /var/www/moodle/config.php

RUN mkdir -p /var/www/moodledata && \
  mkdir -p /var/www/moodledata/lang

RUN curl -fsSL -o /tmp/zh_cn.zip \
  https://download.moodle.org/download.php/langpack/5.3/zh_cn.zip && \
  unzip /tmp/zh_cn.zip -d /tmp && \
  mv /tmp/zh_cn /var/www/moodledata/lang && \
  curl -fsSL -o /tmp/availability_coursecompleted.zip \
  https://marketplace.moodle.com/api/plugins/availability_coursecompleted/versions/2026070100/download && \
  mkdir -p /tmp/mods/availability && \
  unzip /tmp/availability_coursecompleted.zip -d /tmp/mods/availability && \
  mv /tmp/mods/availability/coursecompleted /var/www/moodle/public/availability/condition/coursecompleted && \
  curl -fsSL -o /tmp/enrol_coursecompleted.zip \
  https://marketplace.moodle.com/api/plugins/enrol_coursecompleted/versions/2026060600/download && \
  mkdir -p /tmp/mods/enrol && \
  unzip /tmp/enrol_coursecompleted.zip -d /tmp/mods/enrol && \
  mv /tmp/mods/enrol/coursecompleted /var/www/moodle/public/enrol/coursecompleted && \
  curl -fsSL -o /tmp/availability_othercompleted.zip \
  https://marketplace.moodle.com/api/plugins/availability_othercompleted/versions/2023050310/download && \
  mkdir -p /tmp/mods/availability && \
  unzip /tmp/availability_othercompleted.zip -d /tmp/mods/availability && \
  mv /tmp/mods/availability/othercompleted /var/www/moodle/public/availability/condition/othercompleted

COPY .htaccess /var/www/moodle/public/.htaccess

FROM php:8.4.27-apache AS run

RUN apt-get update && apt-get install -y \
  locales-all zip libzip-dev libpng-dev libicu-dev libxml2-dev libpq-dev && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*
RUN docker-php-ext-install zip gd intl soap exif mysqli pgsql
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
RUN echo 'max_input_vars = 10000' >> /usr/local/etc/php/conf.d/docker-php-moodle.ini
COPY php-opcache.ini /usr/local/etc/php/conf.d/opcache.ini

RUN a2enmod rewrite remoteip
ADD remoteip.conf /etc/apache2/conf-enabled/remoteip.conf
ADD trusted-proxies.lst /etc/apache2/trusted-proxies.lst

COPY --from=build /var/www/moodle /var/www/moodle
RUN rm -rf /var/www/html && ln -s /var/www/moodle/public /var/www/html
COPY --from=build /var/www/moodledata /var/www/moodledata
RUN chown -R www-data:www-data /var/www/moodledata && \
  chmod -R 777 /var/www/moodledata

EXPOSE 80
