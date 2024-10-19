#!/bin/bash

# rclone配置文件下载直链
mkdir -p /root/.config/rclone/ &&
wget --no-check-certificate "$URL" -O /root/.config/rclone/rclone.conf &&
mkdir -p /rclone-mount

# rclone 挂载，以后台运行
nohup rclone mount $REMOTE /rclone-mount \
  --allow-non-empty \
  --allow-other \
  --buffer-size 64M \
  --cache-dir /cache \
  --vfs-cache-mode writes \
  --vfs-cache-max-size 1G \
  --vfs-read-chunk-size 5M \
  --transfers 8 > rclone.log 2>&1 &

if [ $? -eq 0 ];then

java -jar /usr/bin/cryptomator.jar \
    --vault $VAULT_NAME=$VAULT_PATH --password $VAULT_NAME=$VAULT_PASS \
    --bind $VAULT_BIND --port $CRYPTOMATOR_PORT \
    --fusemount $VAULT_MOUNT

fi
