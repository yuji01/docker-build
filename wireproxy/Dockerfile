# Start by building the application.
FROM docker.io/golang as build
RUN apt update \
    && apt install -y git \
    && git clone https://github.com/pufferffish/wireproxy.git /usr/src/wireproxy
WORKDIR /usr/src/wireproxy

RUN make

# Now copy it into our base image.
#FROM gcr.io/distroless/static-debian11:nonroot
FROM alpine

COPY --from=build /usr/src/wireproxy/wireproxy /usr/bin/wireproxy

VOLUME [ "/etc/wireproxy"]

ENTRYPOINT [ "/usr/bin/wireproxy" ]

CMD [ "--config", "/etc/wireproxy/wireproxy.conf" ]

LABEL org.opencontainers.image.title="wireproxy"
LABEL org.opencontainers.image.description="Wireguard client that exposes itself as a socks5 proxy"
LABEL org.opencontainers.image.licenses="ISC"
