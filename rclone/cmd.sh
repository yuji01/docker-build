#! /bin/bash
# 启动 rclone，并将输出重定向到 stdout
rclone --config /app/rclone.conf mount $REMOTE /mnt \
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

# 持续运行以保持容器活动
wait
