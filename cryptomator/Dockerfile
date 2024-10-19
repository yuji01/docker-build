FROM alpine:latest AS builder

RUN apk --no-cache add bash wget curl unzip\
    # 根据平台动态下载 rclone
    && version=$(echo $(curl -fsS https://downloads.rclone.org/version.txt)|grep -o v.*) \
    && [ "$(uname -m)" = "x86_64" ] && OS_type=amd64 || OS_type=arm64 \
    && wget https://github.com/rclone/rclone/releases/download/${version}/rclone-${version}-linux-${OS_type}.zip \
    # 解压文件
    && unzip rclone-${version}-linux-${OS_type}.zip \
    && cp rclone-${version}-linux-${OS_type}/rclone /usr/local/bin/rclone 

RUN wget https://github.com/cryptomator/cli/releases/download/0.5.1/cryptomator-cli-0.5.1.jar -O /usr/bin/cryptomator.jar


FROM openjdk:17-slim # 最终构建
# FROM openjdk:11-jre-slim
# JDK could bloat the image size, only need JRE. But there is no 17-jre build



ENV VAULT_NAME demoVault
ENV VAULT_PATH /cryptomatorDir
ENV VAULT_PASS password
ENV VAULT_BIND 0.0.0.0
ENV CRYPTOMATOR_PORT 5005
ENV VAULT_MOUNT /mnt
ENV URL ""
ENV REMOTE ""

EXPOSE 5005

COPY --from=builder /usr/local/bin/rclone /usr/local/bin/rclone
COPY --from=builder /usr/bin/cryptomator.jar /usr/bin/cryptomator.jar
COPY start.sh /app/start.sh

WORKDIR /app


# change permission
RUN apt update \
&& apt install -y wget fuse && chmod +x /app/start.sh

# run at startup
CMD /app/start.sh
