#!/bin/bash
sleep 3
# 捕捉 SIGTERM 信号，确保在容器关闭时卸载挂载点
trap "fusermount -u /rclone-mount; exit" SIGTERM

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
  --log-level INFO > /proc/1/fd/1 2>&1
