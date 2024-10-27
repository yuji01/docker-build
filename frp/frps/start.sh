#! /bin/sh

# 下载配置文件
wget -q --no-check-certificate "$URL" -O /app/frps.toml && /app/frps --config /app/frps.toml
