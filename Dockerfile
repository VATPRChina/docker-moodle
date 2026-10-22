FROM php:8.2.35-apache

RUN apt-get update && apt-get install -y \
    locales-all zip libzip-dev libpng-dev libicu-dev libxml2-dev libpq-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
RUN docker-php-ext-install zip gd intl soap exif mysqli opcache pgsql
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
RUN echo 'max_input_vars = 10000' >> /usr/local/etc/php/conf.d/docker-php-moodle.ini
COPY php-opcache.ini /usr/local/etc/php/conf.d/opcache.ini

RUN a2enmod rewrite remoteip
ADD remoteip.conf /etc/apache2/conf-enabled/remoteip.conf
ADD trusted-proxies.lst /etc/apache2/trusted-proxies.lst

RUN curl -fsSL -o /tmp/moodle.tgz https://download.moodle.org/download.php/direct/stable500/moodle-latest-500.tgz && \
    tar -xzf /tmp/moodle.tgz -C /var/www/html --strip-components=1 && \
    rm /tmp/moodle.tgz
RUN mkdir -p /var/www/moodledata && \
    mkdir -p /var/www/moodledata/lang && \
    chown -R www-data:www-data /var/www/moodledata && \
    chmod -R 777 /var/www/moodledata
COPY config.php /var/www/html/config.php
    
RUN curl -fsSL -o /tmp/zh_cn.zip \
    https://download.moodle.org/download.php/direct/langpack/5.0/zh_cn.zip && \
    unzip /tmp/zh_cn.zip -d /tmp && \
    mv /tmp/zh_cn /var/www/moodledata/lang && \
  curl -fsSL -o /tmp/availability_coursecompleted.zip \
    https://marketplace.moodle.com/api/plugins/availability_coursecompleted/versions/2025043000/download && \
    mkdir -p /tmp/mods/availability && \
    unzip /tmp/availability_coursecompleted.zip -d /tmp/mods/availability && \
    mv /tmp/mods/availability/coursecompleted /var/www/html/availability/condition/coursecompleted && \
  curl -fsSL -o /tmp/enrol_coursecompleted.zip \
    https://marketplace.moodle.com/api/plugins/enrol_coursecompleted/versions/2025041600/download && \
    mkdir -p /tmp/mods/enrol && \
    unzip /tmp/enrol_coursecompleted.zip -d /tmp/mods/enrol && \
    mv /tmp/mods/enrol/coursecompleted /var/www/html/enrol/coursecompleted && \
  curl -fsSL -o /tmp/availability_othercompleted.zip \
    https://marketplace.moodle.com/api/plugins/availability_othercompleted/versions/2023050310/download && \
    mkdir -p /tmp/mods/availability && \
    unzip /tmp/availability_othercompleted.zip -d /tmp/mods/availability && \
    mv /tmp/mods/availability/othercompleted /var/www/html/availability/condition/othercompleted

EXPOSE 80
