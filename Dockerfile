FROM php:8.1-apache

WORKDIR /var/www/html

RUN apt-get update && apt-get install -y \
    git \
    unzip \
    zip \
    curl \
    libzip-dev \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libonig-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_mysql gd mbstring zip

RUN pecl install mongodb \
    && docker-php-ext-enable mongodb

RUN echo "memory_limit=1024M" > /usr/local/etc/php/conf.d/custom.ini \
 && echo "upload_max_filesize=1024M" >> /usr/local/etc/php/conf.d/custom.ini \
 && echo "post_max_size=1024M" >> /usr/local/etc/php/conf.d/custom.ini

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

COPY composer.json composer.lock ./

RUN composer install --no-dev --optimize-autoloader

COPY . .

RUN a2enmod rewrite

EXPOSE 80