# 自动加/解密文件 网盘版
- 新版本！！！

> 在服务器端自动加密，网盘文件是被加密的，但是服务器端内程序却不受影响

- docker-compose.yml
```yaml
services:
    app:
        image: yujibuzailai/cryptomator-cli
        container_name: cryptomator
        cap_add:
            - SYS_ADMIN
        devices:
            - /dev/fuse
        security_opt:
            - apparmor:unconfined
        user: 0:0
        environment:
            "VAULT_PASS": ""
            "URL": "" # 配置文件下载直链
            "REMOTE": "" # rclone远程挂载路径
        volumes:
            - '/dev/fuse:/dev/fuse'
            - './:/mnt:shared' # 加密文件解密路径
```

## 前提
1. 用 [Cryptomator](https://cryptomator.org/) 准备一个加密的保险库，以 `Test` 为例
2. 记得备份好解密密码和密钥
3. 将 `Test` 文件放入 Onedrive 根目录，其实你放其他路径也可以
4. 将 Onedrive:/Test 填入 环境变量
```
"REMOTE": "onedrive_e5_naruto:/Test"
```
5. 填入保险库密码
```
"VAULT_PASS": "@PASSword123!"
```
6. 填入 rclone 配置文件的下载地址，必须是直链
7. 将 `/mnt` 路径映射到你需要的地方，例如 `./files`
8. 启动容器：`docker compose up -d`
9. 等待容器启动完成即可在 `./files` 查看解密的文件，接下来往这个路径传输文件即可
