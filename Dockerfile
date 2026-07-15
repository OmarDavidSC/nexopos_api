FROM php:8.1-apache

WORKDIR /var/www/html

RUN apt-get update && apt-get install -y \
    git \
    unzip \
    zip \
    curl \
    autoconf \
    gcc \
    g++ \
    make \
    pkg-config \
    libssl-dev \
    libzip-dev \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libonig-dev

# Extensiones PHP
RUN docker-php-ext-configure gd --with-freetype --with-jpeg

RUN docker-php-ext-install -j$(nproc) \
    pdo \
    pdo_mysql \
    gd \
    mbstring \
    zip

# MongoDB para PHP 7.4
RUN pecl channel-update pecl.php.net && \
    pecl install mongodb-1.16.2 && \
    docker-php-ext-enable mongodb

# Configuración PHP
RUN echo "memory_limit=1024M" > /usr/local/etc/php/conf.d/custom.ini && \
    echo "upload_max_filesize=1024M" >> /usr/local/etc/php/conf.d/custom.ini && \
    echo "post_max_size=1024M" >> /usr/local/etc/php/conf.d/custom.ini

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- \
    --install-dir=/usr/local/bin \
    --filename=composer


COPY . /var/www/html

COPY config/000-default.conf /etc/apache2/sites-available/000-default.conf

RUN a2enmod rewrite headers

# COPY . .

RUN composer config --global audit.block-insecure false

RUN composer update -W

RUN a2enmod rewrite
RUN a2enmod headers

RUN rm -rf /var/lib/apt/lists/*