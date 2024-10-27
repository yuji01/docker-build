#! /bin/sh

# 下载配置文件
wget -q --no-check-certificate "$URL" -O /app/frpc.toml && /app/frpc --config /app/frpc.toml
