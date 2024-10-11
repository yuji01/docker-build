FROM alpine:latest

# 设置环境变量
ENV DANTE_VER=1.4.3
ENV DANTE_URL=https://www.inet.no/dante/files/dante-$DANTE_VER.tar.gz

RUN apk add --no-cache --virtual .build-deps \
        build-base \
        curl \
        linux-pam-dev && \
        install -v -d /tmp && \
        curl -sSL $DANTE_URL -o /tmp/dante.tar.gz && \
        tar -C /tmp -vxzf /tmp/dante.tar.gz && \
        cd /tmp/dante-$DANTE_VER && \
        # https://lists.alpinelinux.org/alpine-devel/3932.html
        ac_cv_func_sched_setscheduler=no ./configure --build=x86_64-unknown-linux-gnu && \
        make -j install && \
        cd / && rm -r /tmp && \
        apk del .build-deps && \
        apk add --no-cache \
            linux-pam
        
COPY sockd.conf /etc/

COPY docker-entrypoint.sh /

EXPOSE 1080

ENTRYPOINT ["sh", "-c", "/docker-entrypoint.sh"]

CMD ["sockd"]
