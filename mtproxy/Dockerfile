# 第一阶段：编译和构建代码，使用 Debian 作为基础镜像，其中build是一个标志
FROM ubuntu:latest AS build

# 设置工作目录的环境变量
ENV WORKDIR=/home/mtproxy

# 设置工作目录
WORKDIR $WORKDIR

RUN apt update \
    && apt install -y git curl build-essential libssl-dev zlib1g-dev \
    && mkdir build \
    && cd build \
    && git clone https://github.com/ellermister/MTProxyC --depth=1 MTProxy \
    && cd MTProxy \
    && make \
    && cd objs/bin \
    && chmod +x mtproto-proxy \
    && echo "编译mtproto-proxy成功"

# 第二阶段：最终运行阶段
FROM --platform=$TARGETPLATFORM nginx:1.23.2

# 设置工作目录的环境变量
ENV WORKDIR=/home/mtproxy

# 设置工作目录
WORKDIR $WORKDIR

# setup config
RUN set -ex \
    && apt-get update \
    && apt install -y --no-install-recommends git \
    && git clone https://github.com/ellermister/mtproxy.git $WORKDIR \
    && cd $WORKDIR \
    && cp src/* /usr/share/nginx/html \
    && rm -rf .git \
    && cp mtproxy-entrypoint.sh /docker-entrypoint.d/40-mtproxy-start.sh \
    && chmod +x /docker-entrypoint.d/40-mtproxy-start.sh \
    && cp -f nginx/default.conf /etc/nginx/conf.d/default.conf \
    && cp -f nginx/ip_white.conf /etc/nginx/ip_white.conf \
    && cp -f nginx/nginx.conf /etc/nginx/nginx.conf \
    && sed -i 's/port=8443/port=8443/g; s/web_port=8888/web_port=8080/g' $WORKDIR/mtp_config.example

# 复制第一阶段的构建结果到最终运行时镜像
COPY --from=build $WORKDIR/build/MTProxy/objs/bin/mtproto-proxy $WORKDIR/mtproto-proxy

RUN set -ex \
    && apt-get update \
    && apt install -y --no-install-recommends git wget curl iproute2 php7.4-fpm vim-common net-tools ntpdate procps\
    && sed -i 's/^user\s*=[^\r]\+/user = root/' /etc/php/7.4/fpm/pool.d/www.conf \
    && sed -i 's/^group\s*=[^\r]\+/group = root/' /etc/php/7.4/fpm/pool.d/www.conf \
    && mkdir /run/php -p && mkdir $WORKDIR/pid \
    && apt-get purge -y git build-essential libssl-dev zlib1g-dev \
    && apt-get clean \
    && apt-get autoremove --purge -y \
    && rm -rf /var/lib/apt/lists/*

# 暴露必要的端口
EXPOSE 80 443
