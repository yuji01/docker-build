# 构建镜像，参考官方Dockerfile https://github.com/rclone/rclone/blob/master/Dockerfile
FROM alpine:latest

WORKDIR /app

COPY start.sh /app/start.sh

RUN apk --no-cache add bash wget curl ca-certificates fuse3 tzdata \
    && echo "user_allow_other" >> /etc/fuse.conf \
    # 根据平台动态下载 rclone
    && version=$(echo $(curl -fsS https://downloads.rclone.org/version.txt)|grep -o v.*) \
    && wget https://github.com/rclone/rclone/releases/download/${version}/rclone-${version}-linux-${OS_type}.zip \
    # 解压文件
    && unzip rclone-${version}-linux-${OS_type}.zip \
    && cp rclone-${version}-linux-${OS_type}/rclone /usr/local/bin/rclone \
    # 删除多余文件
    && rm -rf rclone-${version}-linux-${OS_type}* \
    # 配置时区
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    # 配置权限
    && chmod +x /usr/local/bin/rclone \
    && chmod +x /app/start.sh \
    # 删除缓存
    && rm -rf /var/cache/apk/*

# 创建用户和用户组
RUN addgroup -g 1009 rclone && adduser -u 1009 -Ds /bin/sh -G rclone rclone

ENTRYPOINT [ "/app/start.sh" ]
