# Base image
FROM php:8.3-apache

# Cài extension PHP cần thiết
RUN apt-get update && apt-get install -y \
    git unzip zip curl libzip-dev libpng-dev libjpeg-dev libfreetype6-dev libonig-dev libxml2-dev libicu-dev \
    && docker-php-ext-install pdo pdo_mysql zip mbstring exif pcntl bcmath intl

# Bật mod_rewrite cho Laravel routing
RUN a2enmod rewrite

# Cài Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Laravel root
WORKDIR /var/www/html

# Copy toàn bộ project vào container
COPY . .

# Cài package PHP (chạy trên container)
RUN composer install --no-dev --optimize-autoloader

# Cấp quyền thư mục cần thiết
RUN mkdir -p storage/framework/{cache,sessions,views} && \
    mkdir -p bootstrap/cache && \
    chown -R www-data:www-data storage bootstrap/cache

# Cấu hình Apache dùng public làm document root
ENV APACHE_DOCUMENT_ROOT /var/www/html/public

# Cập nhật VirtualHost trỏ đúng vào public/
RUN sed -ri -e 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/000-default.conf

# Expose cổng mặc định
EXPOSE 8080

# Khởi động Laravel + Apache
CMD php artisan config:cache && php artisan migrate --force && apache2-foreground
