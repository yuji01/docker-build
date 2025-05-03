FROM alpine:latest AS builder

RUN apk --no-cache add bash wget curl unzip\
    # 根据平台动态下载 rclone
    && version=$(echo $(curl -fsS https://downloads.rclone.org/version.txt)|grep -o v.*) \
    && [ "$(uname -m)" = "x86_64" ] && OS_type=amd64 || OS_type=arm64 \
    && wget https://github.com/rclone/rclone/releases/download/${version}/rclone-${version}-linux-${OS_type}.zip \
    # 解压文件
    && unzip rclone-${version}-linux-${OS_type}.zip \
    && cp rclone-${version}-linux-${OS_type}/rclone /usr/local/bin/rclone 

FROM ubuntu

ENV VAULT_PATH=/rclone-mount \
    VAULT_PASS=password \
    VAULT_MOUNT=/mnt \
    URL="" \
    REMOTE=""


COPY --from=builder /usr/local/bin/rclone /usr/local/bin/rclone

WORKDIR /app


COPY supervisord/*.sh /app/

RUN apt update \
    && apt install -y wget fuse3 unzip supervisor \
    && echo "user_allow_other" >> /etc/fuse.conf \
    && mkdir -p /etc/supervisor/conf.d \
    && chmod +x /usr/local/bin/rclone \
    && chmod +x /app/*.sh \
    && touch /var/log/supervisord.log

RUN wget -q https://github.com/cryptomator/cli/releases/download/0.6.1/cryptomator-cli-0.6.1-linux-x64.zip \
    && unzip cryptomator-cli-0.6.1-linux-x64.zip -d /tmp/ \
    && rm cryptomator-cli-0.6.1-linux-x64.zip \
    && mv /tmp/cryptomator-cli/ /app/ \
    && bash /app/cryptomator-cli/cryptomator-cli_completion.sh \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

COPY supervisord/supervisord.conf /etc/supervisor/conf.d/

# run at startup
#ENTRYPOINT [ "/app/start.sh" ]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
