# 构建镜像，参考官方Dockerfile https://github.com/rclone/rclone/blob/master/Dockerfile
FROM alpine:latest AS builder

RUN apk --no-cache add bash wget curl unzip\
    # 根据平台动态下载 rclone
    && version=$(echo $(curl -fsS https://downloads.rclone.org/version.txt)|grep -o v.*) \
    && [ "$(uname -m)" = "x86_64" ] && OS_type=amd64 || OS_type=arm64 \
    && wget https://github.com/rclone/rclone/releases/download/${version}/rclone-${version}-linux-${OS_type}.zip \
    # 解压文件
    && unzip rclone-${version}-linux-${OS_type}.zip \
    && cp rclone-${version}-linux-${OS_type}/rclone /usr/local/bin/rclone

# 最终构建
FROM alpine:latest 

WORKDIR /app

COPY *.sh /app/

COPY --from=builder /usr/local/bin/rclone /usr/local/bin/rclone

RUN apk --no-cache add bash wget fuse3 supervisor \
    && echo "user_allow_other" >> /etc/fuse.conf \
    # 配置权限
    && chmod +x /usr/local/bin/rclone \
    && chmod +x /app/*.sh \
    # 删除缓存
    && rm -rf /var/cache/apk/*

# 创建用户和用户组
RUN addgroup -g 1009 rclone && adduser -u 1009 -Ds /bin/sh -G rclone rclone

COPY supervisord.conf /etc/supervisor/conf.d/

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
