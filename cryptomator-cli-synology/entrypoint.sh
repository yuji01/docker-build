#!/bin/sh
# cryptomator-cli 容器入口：解锁保险库并挂载，收到 SIGTERM/SIGINT 时优雅卸载。
#
# 环境变量
#   VAULT_PATH       加密保险库目录（含 vault.cryptomator），默认 /cryptonator-mount
#   VAULT_MOUNT      解密后的挂载点，默认 /mnt
#   VAULT_PASS       保险库密码
#   VAULT_PASS_FILE  从文件读取密码（优先于 VAULT_PASS），UTF-8 编码
#   MOUNTER          fuse（默认）或 webdav
#   MOUNT_OPTIONS    额外的 libfuse 挂载参数，空格分隔，如 "-oallow_other"（对应 -mop）
#   WEBDAV_PORT      webdav 模式的监听端口（对应 --loopbackPort）
#                    注意：官方 FallbackMounter 只监听 localhost，会忽略监听地址参数，
#                    所以 ports 映射无效，必须配合 network_mode: host 才能从容器外访问。
#   VERBOSE          设为 1 打开 cryptomator-cli 详细日志（排查问题用）
#   MOUNT_TIMEOUT    等待挂载成功的秒数，默认 60；超时会打印诊断信息
#   EXTRA_ARGS       原样追加给 `cryptomator-cli unlock` 的参数
set -u

CLI="${CRYPTOMATOR_CLI:-/opt/cryptomator-cli/bin/cryptomator-cli}"
VAULT_PATH="${VAULT_PATH:-/cryptonator-mount}"
VAULT_MOUNT="${VAULT_MOUNT:-/mnt}"
VAULT_MOUNT="${VAULT_MOUNT%/}"
MOUNTER="${MOUNTER:-fuse}"
READY_FILE=/tmp/.cryptomator-ready

# cryptomator-cli 会递归遍历 cryptomator.pluginDir（默认=当前目录）找插件。
# 必须在空目录运行并显式指定，否则工作目录是 / 时会扫描整个文件系统（含 NAS 保险库）而卡死。
PLUGIN_DIR="${CRYPTOMATOR_PLUGIN_DIR:-/opt/cryptomator-plugins}"
mkdir -p "$PLUGIN_DIR" && cd "$PLUGIN_DIR" || cd /tmp
case "${JAVA_TOOL_OPTIONS:-}" in
    *cryptomator.pluginDir*) ;;
    *) export JAVA_TOOL_OPTIONS="-Dcryptomator.pluginDir=$PLUGIN_DIR ${JAVA_TOOL_OPTIONS:-}" ;;
esac

log() { printf '%s [entrypoint] %s\n' "$(date '+%F %T')" "$*"; }

is_fuse_mounted() {
    awk -v m="$VAULT_MOUNT" '$2 == m && $3 ~ /^fuse/ { ok = 1 } END { exit !ok }' /proc/self/mounts 2>/dev/null
}

fuse_unmount() {
    # -z 懒卸载：即使还有文件句柄也能释放挂载点，避免留下 "Transport endpoint is not connected"
    fusermount3 -uz "$VAULT_MOUNT" 2>/dev/null || fusermount -uz "$VAULT_MOUNT" 2>/dev/null || true
}

# ---- healthcheck 子命令 -------------------------------------------------
if [ "${1:-}" = "healthcheck" ]; then
    if [ "$MOUNTER" = "fuse" ]; then
        is_fuse_mounted
    else
        [ -f "$READY_FILE" ]
    fi
    exit $?
fi

# ---- 参数检查 -----------------------------------------------------------
if [ ! -d "$VAULT_PATH" ]; then
    log "ERROR: 保险库目录 $VAULT_PATH 不存在，请检查 volumes 映射（NAS 存储是否已挂载？）"
    exit 1
fi
if [ ! -f "$VAULT_PATH/vault.cryptomator" ]; then
    log "ERROR: $VAULT_PATH 下没有 vault.cryptomator，这不是 Cryptomator 保险库（或存储还没挂载好）"
    exit 1
fi

if [ -n "${VAULT_PASS_FILE:-}" ]; then
    if [ ! -r "$VAULT_PASS_FILE" ]; then
        log "ERROR: 无法读取 VAULT_PASS_FILE=$VAULT_PASS_FILE"
        exit 1
    fi
    pass_arg="--password:file=$VAULT_PASS_FILE"
elif [ -n "${VAULT_PASS:-}" ]; then
    pass_arg="--password:env=VAULT_PASS"
else
    log "ERROR: 请设置 VAULT_PASS 或 VAULT_PASS_FILE"
    exit 1
fi

set -- unlock
[ "${VERBOSE:-0}" = "1" ] && set -- "$@" -v
case "$MOUNTER" in
    fuse)
        # 容器异常退出后，挂载点上可能残留失效的 FUSE 挂载，先清掉
        if is_fuse_mounted; then
            log "发现残留的 FUSE 挂载 $VAULT_MOUNT，先卸载"
            fuse_unmount
        fi
        set -- "$@" --mounter=org.cryptomator.frontend.fuse.mount.LinuxFuseMountProvider \
                    --mountPoint="$VAULT_MOUNT"
        ;;
    webdav)
        set -- "$@" --mounter=org.cryptomator.frontend.webdav.mount.FallbackMounter
        [ -n "${WEBDAV_PORT:-}" ] && set -- "$@" --loopbackPort="$WEBDAV_PORT"
        ;;
    *)
        log "ERROR: MOUNTER 只能是 fuse 或 webdav，当前是 '$MOUNTER'"
        exit 1
        ;;
esac
set -- "$@" "$pass_arg"
# 故意不加引号：按空格拆分成多个参数
for opt in ${MOUNT_OPTIONS:-}; do set -- "$@" "-mop=$opt"; done
# shellcheck disable=SC2086
[ -n "${EXTRA_ARGS:-}" ] && set -- "$@" $EXTRA_ARGS
set -- "$@" "$VAULT_PATH"

# ---- 启动并转发信号 -----------------------------------------------------
child=""

shutdown() {
    trap '' TERM INT
    log "收到停止信号，正在卸载保险库"
    if [ -n "$child" ]; then
        kill -TERM "$child" 2>/dev/null
        i=0
        while kill -0 "$child" 2>/dev/null && [ "$i" -lt 8 ]; do
            sleep 1
            i=$((i + 1))
        done
        kill -KILL "$child" 2>/dev/null
        wait "$child" 2>/dev/null
    fi
    [ "$MOUNTER" = "fuse" ] && fuse_unmount
    rm -f "$READY_FILE"
    exit 0
}
trap shutdown TERM INT

rm -f "$READY_FILE"
log "启动 cryptomator-cli（mounter=$MOUNTER，vault=$VAULT_PATH）"
"$CLI" "$@" &
child=$!

diagnose() {
    log "---- 诊断信息 ----"
    log "内核: $(uname -r)  熵池: $(cat /proc/sys/kernel/random/entropy_avail 2>/dev/null)"
    log "/dev/fuse: $(ls -l /dev/fuse 2>&1)"
    capeff=$(awk '/^CapEff/ {print $2}' /proc/self/status 2>/dev/null)
    if [ -n "$capeff" ] && [ $((0x$capeff & 0x200000)) -ne 0 ]; then
        log "SYS_ADMIN 权限: 有"
    else
        log "SYS_ADMIN 权限: 没有（检查 cap_add: SYS_ADMIN）"
    fi
    log "挂载点: $(ls -ld "$VAULT_MOUNT" 2>&1)"
    log "当前 fuse 挂载: $(awk '$3 ~ /^fuse/ {print $2}' /proc/self/mounts | tr '\n' ' ')"
    if kill -0 "$child" 2>/dev/null; then
        log "cryptomator-cli 仍在运行但未完成挂载，请设置 VERBOSE=1 重试获取详细日志"
    else
        log "cryptomator-cli 已退出"
    fi
    log "------------------"
}

# 后台确认挂载成功，只用于日志和 webdav 的就绪标记
(
    i=0
    while [ "$i" -lt "${MOUNT_TIMEOUT:-60}" ]; do
        kill -0 "$child" 2>/dev/null || exit 0
        if [ "$MOUNTER" = "fuse" ]; then
            if is_fuse_mounted; then
                touch "$READY_FILE"
                log "保险库已挂载到 $VAULT_MOUNT"
                exit 0
            fi
        elif [ "$i" -ge 3 ]; then
            touch "$READY_FILE"
            log "WebDAV 服务已启动（具体地址见上方 cryptomator-cli 日志）"
            exit 0
        fi
        i=$((i + 1))
        sleep 1
    done
    log "WARNING: ${MOUNT_TIMEOUT:-60} 秒内没有检测到挂载成功，请检查上方日志"
    [ "$MOUNTER" = "fuse" ] && diagnose
) &

wait "$child"
rc=$?
log "cryptomator-cli 已退出（返回码 $rc）"
[ "$MOUNTER" = "fuse" ] && fuse_unmount
rm -f "$READY_FILE"
exit "$rc"
