#!/bin/sh

if [ ! -f /app/lock ];then

  # 创建 rclone 挂载点
  mkdir -p /mnt
  
  # 创建 rclone 配置目录并下载配置文件
  wget --no-check-certificate -q "$URL" -O /app/rclone.conf.tmp
  
  if [[ $? -eq 0 ]]; then
    mv /app/rclone.conf.tmp /app/rclone.conf  # 只有下载成功才重命名
  else
    echo "rclone 配置文件下载失败"
  fi
  
  # 显示 rclone 配置文件内容到日志
  cat /app/rclone.conf && touch /app/lock

fi

# 清理逻辑
cleanup() {
    echo "Unmounting /mnt..."
    fusermount -u /mnt
    echo "Unmounted /mnt"
    exit 0
}

# 捕获 SIGTERM 信号
trap cleanup SIGTERM

# 启动 rclone，并将输出重定向到 stdout
rclone --config /app/rclone.conf \
  --umask=0 mount $REMOTE /mnt \
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
  --log-level INFO
