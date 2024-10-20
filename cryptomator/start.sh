#!/bin/bash

# 创建 rclone 配置目录并下载配置文件
mkdir -p /root/.config/rclone/ &&
wget --no-check-certificate "$URL" -O /root/.config/rclone/rclone.conf &&

# 显示 rclone 配置文件内容到日志
cat /root/.config/rclone/rclone.conf
cp /root/.config/rclone/rclone.conf /app/rclone.conf
# 创建 rclone 挂载点
mkdir -p /rclone-mount

# 启动 rclone，并将输出重定向到 stdout
rclone --config /app/rclone.conf mount $REMOTE /rclone-mount \
  --allow-non-empty \
  --allow-other \
  --cache-dir /cache \
  --vfs-cache-mode writes \
  --buffer-size 256M \
  --vfs-cache-max-age 1h \
  --vfs-cache-max-size 2G \
  --vfs-read-chunk-size 64M \
  --vfs-read-chunk-size-limit 2G \
  --transfers 16 \
  --dir-cache-time 72h \
  --fast-list \
  --log-level INFO > /proc/1/fd/1 2>&1 &

# 捕捉 SIGTERM 信号，确保在容器关闭时卸载挂载点
trap "umount -u /rclone-mount" SIGTERM

sleep 3

# 运行解密程序 Cryptomator，将输出也重定向到 stdout
java -jar /usr/bin/cryptomator.jar \
    --vault $VAULT_NAME=$VAULT_PATH --password $VAULT_NAME=$VAULT_PASS \
    --bind $VAULT_BIND --port $CRYPTOMATOR_PORT \
    --fusemount $VAULT_NAME=$VAULT_MOUNT > /proc/1/fd/1 2>&1 &

# 持续运行以保持容器活动
wait
