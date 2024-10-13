#! /bin/bash

# rclone配置文件下载直链
wget --no-check-certificate "$URL" -O /app/rclone.conf &&

# rclone 启动，其中 --config /app/rclone.conf 不可改
rclone --config /app/rclone.conf 
