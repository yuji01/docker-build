FROM alpine:latest AS builder

RUN apk --no-cache add bash wget curl unzip \
    && mkdir -p /tmp \
    && wget -O /tmp/lsky.zip https://github.com/lsky-org/lsky-pro/releases/download/2.1/lsky-pro-2.1.zip \
    # 解压文件
    && unzip /tmp/lsky.zip -d /tmp/lsky-pro-2.1 \
    && echo "解压完成"


FROM php:8.0-fpm

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       nginx \
       libxml2-dev \
       libonig-dev \
       libmagickwand-dev \
       python3-pip \
    && pip3 install supervisor \
    && docker-php-ext-install bcmath ctype dom fileinfo mbstring pdo tokenizer xml pdo_mysql \
    # 👉 关键修复：用 printf 向 pecl 自动发送回车，避免卡死
    && printf "\n" | pecl install imagick \
    && docker-php-ext-enable imagick pdo_mysql \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini \
    && sed -i 's/^open_basedir\s*=.*/; open_basedir =/' /usr/local/etc/php/php.ini

COPY nginx.conf /etc/nginx/nginx.conf
#COPY ./lsky-pro-2.1 /var/www/html
COPY --from=builder /tmp/lsky-pro-2.1 /var/www/html

WORKDIR /var/www/html

RUN chown -R www-data:www-data /var/www/html \
    && find /var/www/html -type d -exec chmod 755 {} \; \
    && find /var/www/html -type f -exec chmod 644 {} \;

EXPOSE 80

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD ["/usr/local/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
