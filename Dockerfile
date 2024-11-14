FROM php:8.2-apache

RUN a2enmod rewrite

RUN apt-get update && apt-get install -y \
    locales-all zip libzip-dev libpng-dev libicu-dev libxml2-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
RUN docker-php-ext-install zip gd intl soap exif mysqli opcache
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
RUN echo 'max_input_vars = 10000' >> /usr/local/etc/php/conf.d/docker-php-moodle.ini
COPY php-opcache.ini /usr/local/etc/php/conf.d/opcache.ini

RUN curl -fsSL -o /tmp/moodle.tgz https://download.moodle.org/download.php/direct/stable405/moodle-latest-405.tgz && \
    tar -xzf /tmp/moodle.tgz -C /var/www/html --strip-components=1 && \
    rm /tmp/moodle.tgz
RUN mkdir -p /var/www/moodledata && \
    mkdir -p /var/www/moodledata/lang && \
    chown -R www-data:www-data /var/www/moodledata && \
    chmod -R 777 /var/www/moodledata
COPY config.php /var/www/html/config.php
    
RUN curl -fsSL -o /tmp/zh_cn.zip \
    https://download.moodle.org/download.php/direct/langpack/4.5/zh_cn.zip && \
    unzip /tmp/zh_cn.zip -d /tmp && \
    mv /tmp/zh_cn /var/www/moodledata/lang && \
  curl -fsSL -o /tmp/availability_coursecompleted.zip \
    https://moodle.org/plugins/download.php/33332/availability_coursecompleted_moodle45_2024100700.zip && \
    mkdir -p /tmp/mods/availability && \
    unzip /tmp/availability_coursecompleted.zip -d /tmp/mods/availability && \
    mv /tmp/mods/availability/coursecompleted /var/www/html/availability/condition/coursecompleted && \
  curl -fsSL -o /tmp/enrol_coursecompleted.zip \
    https://moodle.org/plugins/download.php/33335/enrol_coursecompleted_moodle45_2024100700.zip && \
    mkdir -p /tmp/mods/enrol && \
    unzip /tmp/enrol_coursecompleted.zip -d /tmp/mods/enrol && \
    mv /tmp/mods/enrol/coursecompleted /var/www/html/enrol/coursecompleted && \
  curl -fsSL -o /tmp/editor_marklar.zip \
    https://moodle.org/plugins/download.php/31840/editor_marklar_moodle44_2024030602.zip && \
    mkdir -p /tmp/mods/editor && \
    unzip /tmp/editor_marklar.zip -d /tmp/mods/editor && \
    mv /tmp/mods/editor/marklar /var/www/html/lib/editor/marklar && \
  curl -fsSL -o /tmp/availability_othercompleted.zip \
    https://moodle.org/plugins/download.php/29236/availability_othercompleted_moodle42_2023050310.zip && \
    mkdir -p /tmp/mods/availability && \
    unzip /tmp/availability_othercompleted.zip -d /tmp/mods/availability && \
    mv /tmp/mods/availability/othercompleted /var/www/html/availability/condition/othercompleted

EXPOSE 80
