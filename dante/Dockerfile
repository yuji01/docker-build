FROM    alpine:latest

ENV     DANTE_VER 1.4.2

ENV     DANTE_URL https://www.inet.no/dante/files/dante-$DANTE_VER.tar.gz

ENV     DANTE_SHA 4c97cff23e5c9b00ca1ec8a95ab22972813921d7fbf60fc453e3e06382fc38a7

RUN     apk add --no-cache --virtual .build-deps \
            build-base \
            curl \
            linux-pam-dev && \
        install -v -d /src && \
        curl -sSL $DANTE_URL -o /src/dante.tar.gz && \
        echo "$DANTE_SHA */src/dante.tar.gz" | sha256sum -c && \
        tar -C /src -vxzf /src/dante.tar.gz && \
        cd /src/dante-$DANTE_VER && \
        # https://lists.alpinelinux.org/alpine-devel/3932.html
        ac_cv_func_sched_setscheduler=no ./configure && \
        make -j install && \
        cd / && rm -r /src && \
        apk del .build-deps && \
        apk add --no-cache \
            linux-pam

WORKDIR /app

COPY    sockd.conf /etc/

COPY    docker-entrypoint.sh /app
RUN chmod +x /app/docker-entrypoint.sh

EXPOSE  1080

ENTRYPOINT  ["./docker-entrypoint.sh"]

CMD     ["sockd"]
