# 使用 nginx 基础镜像并根据需要指定平台
FROM --platform=$TARGETPLATFORM nginx:1.23.2 AS build

# 设置工作目录的环境变量
ENV WORKDIR=/home/mtproxy

# 设置工作目录
WORKDIR $WORKDIR

# 安装必要的软件包并克隆 GitHub 存储库
RUN apt-get update && \
    apt-get install -y --no-install-recommends git php7.4-fpm wget curl vim-common net-tools ntpdate procps && \
    git clone https://github.com/ellermister/mtproxy.git $WORKDIR && \
    cd $WORKDIR && \
    cp src/* /usr/share/nginx/html && \
    cp mtproxy-entrypoint.sh /docker-entrypoint.d/40-mtproxy-start.sh && \
    chmod +x /docker-entrypoint.d/40-mtproxy-start.sh && \
    cp -f nginx/default.conf /etc/nginx/conf.d/default.conf && \
    cp -f nginx/ip_white.conf /etc/nginx/ip_white.conf && \
    cp -f nginx/nginx.conf /etc/nginx/nginx.conf

# 构建mtproxy并配置PHP-FPM
RUN bash mtproxy.sh build && \
    sed -i 's/^user\s*=[^\r]\+/user = root/' /etc/php/7.4/fpm/pool.d/www.conf && \
    sed -i 's/^group\s*=[^\r]\+/group = root/' /etc/php/7.4/fpm/pool.d/www.conf && \
    mkdir /run/php -p && mkdir $WORKDIR/pid

# 清理不必要的文件以减小图像大小
RUN apt-get purge -y git && \
    apt-get clean && \
    apt-get autoremove --purge -y && \
    rm -rf /var/lib/apt/lists/* $WORKDIR/MTProxy

# 暴露必要的端口
EXPOSE 80 443
ENTRYPOINT ["/docker-entrypoint.d/40-mtproxy-start.sh"]
