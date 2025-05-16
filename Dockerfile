# syntax=docker/dockerfile:1
FROM php:8.4-fpm-alpine

WORKDIR /var/www/html

RUN apk add --no-cache \
    bash curl git unzip zip mariadb-client \
    libpng-dev libjpeg-turbo-dev libwebp-dev libxpm-dev freetype-dev \
    oniguruma-dev libxml2-dev icu-dev shadow build-base \
  && docker-php-ext-configure gd \
       --with-freetype --with-jpeg --with-webp \
  && docker-php-ext-install \
       pdo pdo_mysql mbstring exif pcntl bcmath gd intl xml \
  && curl -sS https://getcomposer.org/installer \
       | php -- --install-dir=/usr/local/bin --filename=composer

COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf
COPY entrypoint.sh            /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 9000 80
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD        ["php-fpm"]
