FROM alpine:latest

ENV WORKDIR=/app

WORKDIR $WORKDIR

COPY app .
RUN apk update \
    && apk add --no-cache bash jq wget curl tar sed gawk coreutils dcron tzdata \
    && mkdir $WORKDIR/tmp \
    && wget -P ./tmp/ https://github.com/XIU2/CloudflareSpeedTest/releases/latest/download/CloudflareST_linux_amd64.tar.gz \
    && tar -zxf $WORKDIR/tmp/CloudflareST_linux_amd64.tar.gz -C $WORKDIR/tmp/ \
    && mv $WORKDIR/tmp/CloudflareST $WORKDIR/ \
    && chmod +x $WORKDIR/CloudflareST \
    && mv $WORKDIR/tmp/ipv6.txt $WORKDIR/config/ipv6.txt \
    && mv $WORKDIR/tmp/ip.txt $WORKDIR/config/ip.txt \
    && rm -rf /app/tmp/ \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && apk del tzdata \
    && rm -rf /var/cache/apk/* \
    && chmod +x /app/start.sh

CMD ["/bin/sh", "-c", "/app/start.sh && tail -f /dev/null"]
