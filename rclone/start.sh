#! /bin/bash

# rclone配置文件下载直链
wget --no-check-certificate "" -O /app/rclone.conf

if [ -f /app/rclone.conf ]; then

# rclone 启动，其中 --config /app/rclone.conf 不可改
rclone --config /app/rclone.conf 







else
  echo "rclone.conf 配置文件不存在"
fi
