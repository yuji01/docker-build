#!/bin/bash

# 运行解密程序 Cryptomator，将输出也重定向到 stdout
java -jar /usr/bin/cryptomator.jar \
    --vault $VAULT_NAME=$VAULT_PATH --password $VAULT_NAME=$VAULT_PASS \
    --bind $VAULT_BIND --port $CRYPTOMATOR_PORT \
    --fusemount $VAULT_NAME=$VAULT_MOUNT > /proc/1/fd/1 2>&1
