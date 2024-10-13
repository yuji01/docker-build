#! /bin/bash

# rclone配置文件下载直链
mkdir -p /root/.config/rclone/
wget --no-check-certificate "$URL" -O /root/.config/rclone/rclone.conf &&

# rclone 启动，其中 --config /app/rclone.conf 不可改
rclone
