FROM alpine:latest AS builder

RUN apk --no-cache add bash wget curl unzip\
    # 下载文件
    && wget https://pan.narutos.top/d/%E5%88%86%E4%BA%AB/share/Linux/chevereto/cheveretoChinaV4.zip -O /tmp/cheveretoChinaV4.zip \
    # 解压文件
    && unzip -q /tmp/cheveretoChinaV4.zip -d /tmp/html


# 使用官方 PHP 8.0 FPM 镜像作为基础镜像
# 建议8.0！
FROM php:8.0-fpm

# 安装必要的依赖库
# cron 和 sudo 都是必须的
RUN apt-get update && apt-get install -y cron sudo supervisor nginx \
    libmagickwand-dev \
    libexif-dev \
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev \
    libwebp-dev \
    libcurl4-openssl-dev \
    --no-install-recommends

# 安装 PHP 扩展
RUN docker-php-ext-configure gd --with-jpeg --with-freetype --with-webp \
    && docker-php-ext-install gd \
        curl \
        exif \
        fileinfo \
        pdo \
        pdo_mysql \
    && pecl install imagick \
    && docker-php-ext-enable imagick

# 复制文件
COPY supervisord/supervisord.conf /etc/supervisor/conf.d/

# 复制自定义 php.ini
COPY php.ini /usr/local/etc/php/php.ini

# 复制 开心版 文件
COPY --from=builder /tmp/html /var/www/html

# 复制nginx配置文件
COPY nginx/*.conf /etc/nginx/

# 复制 cron 任务
COPY cheveroto_cron_job /etc/cron.d/chevereto
 
# 清理无用的缓存文件
RUN crontab /etc/cron.d/chevereto \
    && touch /var/log/cron.log \
    && touch /var/log/supervisord.log \
    && chown -R www-data:www-data /var/www/html \
    && echo "user = www-data" >> /usr/local/etc/php-fpm.conf \
    && echo "group = www-data" >> /usr/local/etc/php-fpm.conf \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 声明 volume 
VOLUME /var/www/html

# 启动 cron 服务
#CMD cron && php-fpm
CMD ["/usr/bin/supervisord"]
