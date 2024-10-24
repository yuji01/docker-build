#!/bin/bash

# 创建 rclone 挂载点
mkdir -p /rclone-mount

# 创建 rclone 配置目录并下载配置文件
wget --no-check-certificate "$URL" -O /app/rclone.conf &&

# 显示 rclone 配置文件内容到日志
cat /app/rclone.conf

