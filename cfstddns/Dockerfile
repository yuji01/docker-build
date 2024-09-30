FROM alpine:latest

# 设置工作目录
ENV WORKDIR=/app
WORKDIR $WORKDIR

# 将应用程序文件复制到容器
COPY app .

# 根据架构下载不同版本的 CloudflareST
RUN apk update \
    && apk add --no-cache bash jq wget curl tar sed gawk coreutils dcron tzdata proxychains-ng \
    && mkdir $WORKDIR/tmp \
    # 根据平台动态下载 CloudflareST
    && if [ "$(uname -m)" = "x86_64" ]; then \
        wget -P $WORKDIR/tmp/ https://github.com/XIU2/CloudflareSpeedTest/releases/latest/download/CloudflareST_linux_amd64.tar.gz; \
    elif [ "$(uname -m)" = "aarch64" ]; then \
        wget -P $WORKDIR/tmp/ https://github.com/XIU2/CloudflareSpeedTest/releases/latest/download/CloudflareST_linux_arm64.tar.gz; \
    fi \
    # 解压缩下载的文件
    && tar -zxf $WORKDIR/tmp/CloudflareST_linux_*.tar.gz -C $WORKDIR/tmp/ \
    && mv $WORKDIR/tmp/CloudflareST $WORKDIR/ \
    && chmod +x $WORKDIR/CloudflareST \
    && mv $WORKDIR/tmp/ipv6.txt $WORKDIR/config/ipv6.txt \
    && mv $WORKDIR/tmp/ip.txt $WORKDIR/config/ip.txt \
    && rm -rf /app/tmp/ \
    # 配置时区
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && apk del tzdata \
    && rm -rf /var/cache/apk/* \
    && chmod +x /app/start.sh

# 设置启动命令
CMD ["/bin/sh", "-c", "/app/start.sh && tail -f /dev/null"]
