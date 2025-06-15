# Sử dụng PHP 8.2 FPM làm base image
FROM php:8.2

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
RUN chmod -R 775 storage bootstrap/cache \
    && chown -R www-data:www-data .

# Expose port Laravel sẽ chạy
EXPOSE 8000

# Lệnh mặc định để khởi chạy Laravel
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
