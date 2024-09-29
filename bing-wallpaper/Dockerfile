# 使用轻量级的 PHP-FPM 镜像（基于Alpine Linux）
FROM php:8.1-fpm-alpine

# 安装 Nginx 并配置 PHP-FPM
RUN apk --no-cache add nginx \
    && mkdir -p /run/nginx \
    && mkdir -p /var/www/html \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# 复制 Nginx 配置文件
COPY bing-wallpaper/nginx.conf /etc/nginx/nginx.conf

# 复制 PHP 文件到 Nginx Web 根目录
COPY bing-wallpaper/index.php /var/www/html/

# 暴露 80 端口
EXPOSE 80

# 启动 Nginx 和 PHP-FPM 服务
CMD ["sh", "-c", "php-fpm -D && nginx -g 'daemon off;'"]
