#!/bin/sh

if [ -d "$VAULT_PATH" ] && [ "$(ls -A $VAULT_PATH)" ]; then
    
    echo "目录 $VAULT_PATH 存在，运行解密程序"
    
    # 清理逻辑
    cleanup() {
        fusermount -u $VAULT_MOUNT
        exit 0
    }

    # 捕获 SIGTERM 信号
    trap cleanup SIGTERM


    # 运行解密程序 Cryptomator，将输出也重定向到 stdout
    /app/cryptomator-cli/bin/cryptomator-cli unlock \
        --password:env=VAULT_PASS \
        --mounter=org.cryptomator.frontend.fuse.mount.LinuxFuseMountProvider \
        --mountPoint=$VAULT_MOUNT \
        $VAULT_PATH

else
    echo "目录 $VAULT_PATH 不存在或为空"
fi