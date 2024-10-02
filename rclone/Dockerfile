# 构建镜像
FROM alpine:latest

WORKDIR /app

RUN apk --no-cache add bash wget ca-certificates fuse3 tzdata \
    && echo "user_allow_other" >> /etc/fuse.conf \
    # 根据平台动态下载 rclone
    && version=$(echo $(curl -fsS https://downloads.rclone.org/version.txt)|grep -o v.*) \
    && wget https://github.com/rclone/rclone/releases/download/${version}/rclone-${version}-linux-${OS_type}.zip \
    # 解压文件
    && unzip rclone-${version}-linux-${OS_type}.zip \
    && cp rclone-${version}-linux-${OS_type}/rclone /usr/local/bin/rclone \
    # 删除多余文件
    && rm -rf rclone-${version}-linux-${OS_type}* \
    && chmod +x /usr/local/bin/rclone

RUN addgroup -g 1009 rclone && adduser -u 1009 -Ds /bin/sh -G rclone rclone

ENTRYPOINT [ "rclone" ]


ENV XDG_CONFIG_HOME=/config
