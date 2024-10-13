- 用docker挂载网盘

```yaml
services:
    rclone:
        image: yujibuzailai/rclone
        container_name: immich-rclone
        restart: always
        
        cap_add: # 为容器添加 SYS_ADMIN 权限，这在 Linux 上允许更高的系统权限，是为了能够挂载文件系统所必需的。
            - SYS_ADMIN
        devices:
            - /dev/fuse # 使用 /dev/fuse 设备。
        security_opt:
            - apparmor:unconfined # 解除 AppArmor 安全限制
        user: 0:0
        environment:
            "URL": "" # 配置文件下载地址
        volumes:
            #- '/opt/mydocker/run/rclone/start.sh:/app/start.sh'
            - '/dev/fuse:/dev/fuse' # 使得容器能够通过 FUSE (Filesystem in Userspace) 实现文件系统挂载。
            
            - '/opt/mydocker/run/immich/upload_storage:/mnt:shared' # 后面的 /mnt 不要改
        command: 'rclone mount 网盘:/docker/immich/upload_storage /mnt --allow-other --allow-non-empty --vfs-cache-mode writes --cache-dir /tmp --vfs-cache-max-age 1h --vfs-read-chunk-size 32M --vfs-read-chunk-size-limit 2G --buffer-size 64M --no-check-certificate'
        
        healthcheck: # 设置健康检测规则，如果/mnt 目录没有文件，则执行 bash -c 来发送 SIGTERM 和 SIGKILL 以终止进程
            test: ["CMD-SHELL", "test -n \"$(ls -A /mnt)\" || bash -c 'kill -s 15 -1 && (sleep 10; kill -s 9 -1)'"] 
            interval: 5s
            timeout: 10s
            retries: 3
```
