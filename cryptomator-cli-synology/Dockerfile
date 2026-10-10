# syntax=docker/dockerfile:1

# 固定基础镜像版本：ubuntu:latest 会随时间换成带更新 libfuse3 的版本，
# cryptomator-cli 之前就因为 libfuse 3.17.1 挂载失败过（0.6.2 才修复）。
# bookworm 自带 fuse3 3.14，和官方测试环境一致。
FROM debian:bookworm-slim

ARG CRYPTOMATOR_CLI_VERSION=0.6.2
# buildx 会自动传入 amd64 / arm64
ARG TARGETARCH

# 默认值与旧版保持一致，旧的 compose 不用改
ENV VAULT_PATH=/cryptonator-mount \
    VAULT_MOUNT=/mnt \
    MOUNTER=fuse

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates curl unzip fuse3 tini; \
    case "${TARGETARCH}" in \
        amd64) asset=linux-x64 ;; \
        arm64) asset=linux-aarch64 ;; \
        *) echo "unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    curl -fsSL -o /tmp/cli.zip \
        "https://github.com/cryptomator/cli/releases/download/${CRYPTOMATOR_CLI_VERSION}/cryptomator-cli-${CRYPTOMATOR_CLI_VERSION}-${asset}.zip"; \
    unzip -q /tmp/cli.zip -d /opt; \
    rm -f /tmp/cli.zip; \
    echo "user_allow_other" >> /etc/fuse.conf; \
    bash /opt/cryptomator-cli/cryptomator-cli_completion.sh; \
    apt-get purge -y --auto-remove curl unzip; \
    rm -rf /var/lib/apt/lists/*

COPY --chmod=0755 entrypoint.sh /entrypoint.sh

# FUSE 模式下检查挂载点是否真的是 fuse 文件系统，可配合 depends_on: service_healthy
HEALTHCHECK --interval=30s --timeout=5s --start-period=40s --retries=3 \
    CMD ["/entrypoint.sh", "healthcheck"]

# tini 负责回收子进程；stop 时 SIGTERM 由 entrypoint.sh 转发并卸载
ENTRYPOINT ["/usr/bin/tini", "--", "/entrypoint.sh"]
