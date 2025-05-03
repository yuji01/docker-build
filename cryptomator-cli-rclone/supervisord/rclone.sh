#!/bin/sh

if [ ! -f /app/lock ];then

  # 创建 rclone 挂载点
  mkdir -p /rclone-mount
  
  # 创建 rclone 配置目录并下载配置文件
  wget --no-check-certificate "$URL" -O /app/rclone.conf &&
  
  # 显示 rclone 配置文件内容到日志
  cat /app/rclone.conf && touch /app/lock

fi

# 清理逻辑
cleanup() {
    echo "Unmounting /rclone-mount..."
    fusermount -u /rclone-mount
    echo "Unmounted /rclone-mount"
    exit 0
}

# 启动 rclone，并将输出重定向到 stdout
rclone --config /app/rclone.conf \
  --umask=0 mount $REMOTE /rclone-mount \
  --allow-non-empty \
  --allow-other \
  --cache-dir /cache \
  --vfs-cache-mode writes \
  --buffer-size 256M \
  --vfs-cache-max-age 1h \
  --vfs-cache-max-size 2G \
  --vfs-read-chunk-size 64M \
  --vfs-read-chunk-size-limit 2G \
  --transfers 64 \
  --dir-cache-time 72h \
  --fast-list \
  --log-level INFO
