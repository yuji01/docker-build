# 构建镜像
FROM alpine:latest AS builder

RUN apk --no-cache add bash wget curl unzip\
    # 获取最新版本，使用官方api
    && latest_version=$(wget -qO- -t1 -T2 "https://api.github.com/repos/fatedier/frp/releases/latest" | grep "tag_name" | head -n 1 | awk -F ":" '{print $2}' | sed 's/\"//g;s/,//g;s/ //g') \
    
    # 版本，不带v
    && version=$(echo $latest_version | sed 's/^v//') \
    
    # 判断操作系统
    && [ "$(uname -m)" = "x86_64" ] && OS_type=amd64 || OS_type=arm64 \

    # 下载文件 /tmp/frp.tar.gz
    && wget -q https://github.com/fatedier/frp/releases/download/${latest_version}/frp_${version}_linux_${OS_type}.tar.gz -O /tmp/frp.tar.gz \
    
    # 解压文件 ，文件存放在 /tmp/frp_0.61.0_linux_amd64/
    && tar -xzf /tmp/frp.tar.gz -C /tmp/ \
    # 改目录名，文件存放在 /tmp/frp/
    && mv /tmp/frp_${version}_linux_${OS_type} /tmp/frp


FROM alpine:latest
ENV URL=
WORKDIR /app

COPY --from=builder /tmp/frp/frps /app/frps
COPY start.sh /app/

RUN apk add --no-cache tzdata wget \
    && chmod +x /app/frps \
    && chmod +x /app/start.sh

ENTRYPOINT ["/app/start.sh"]