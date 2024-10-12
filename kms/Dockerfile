FROM alpine:latest as builder
WORKDIR /root
RUN apk add --no-cache git make build-base && \
    git clone --branch master --single-branch https://github.com/Wind4/vlmcsd.git && \
    cd vlmcsd/ && \
    make

FROM alpine:latest
# 添加 /app 到环境变量
ENV PATH="/app:${PATH}"

WORKDIR /app
COPY --from=builder /root/vlmcsd/bin/vlmcs /app/vlmcs
COPY --from=builder /root/vlmcsd/bin/vlmcsd /app/vlmcsd

EXPOSE 1688/tcp
CMD [ "/app/vlmcsd", "-P", "1688", "-D", "-d" ]
