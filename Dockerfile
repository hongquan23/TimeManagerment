# Sử dụng PHP 8.2 FPM làm base image
FROM php:8.2-fpm

# Cài đặt các package hệ thống và PHP extension cần thiết cho Laravel
RUN apt-get update && apt-get install -y \
    git \
    curl \
    zip \
    unzip \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    libpq-dev \
    libcurl4-openssl-dev \
    default-mysql-client \
    && docker-php-ext-configure zip \
    && docker-php-ext-install pdo pdo_mysql mbstring zip exif pcntl gd

# Cài Composer từ image chính thức
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Thiết lập thư mục làm việc
WORKDIR /var/www

# Copy toàn bộ source code vào container
COPY . .

# Cài đặt dependency Laravel
RUN composer install --no-dev --no-interaction --optimize-autoloader

# Cấp quyền cho thư mục storage và bootstrap/cache
RUN chown -R www-data:www-data /var/www \
    && chmod -R 775 storage bootstrap/cache

# Mở port 8000 (nếu chạy php artisan serve)
EXPOSE 8000

# Lệnh khởi chạy mặc định: dùng php-fpm (nếu bạn chạy qua nginx)
CMD ["php-fpm"]
