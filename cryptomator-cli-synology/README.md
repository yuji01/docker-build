# cryptomator-cli 容器：自动解密保险库并挂载

把用 [Cryptomator](https://cryptomator.org/) 加密的保险库在服务器端解密挂载，上层程序（如 Immich）读写明文，磁盘/网盘上存的是密文。
支持 `linux/amd64` 和 `linux/arm64`（群晖 x86 / ARM 机型均可），基于官方 [cryptomator/cli](https://github.com/cryptomator/cli)。

## 使用

1. 用 Cryptomator 桌面版创建保险库，**备份好密码和 masterkey**。
2. 把保险库文件夹放到 NAS 上，确认里面有 `vault.cryptomator` 和 `masterkey.cryptomator`。
3. 参考 `docker-compose.synology.yml` 修改路径，把密码写进同目录 `.env`：`VAULT_PASS=你的密码`。
4. `docker compose up -d`，`docker logs -f cryptomator` 看到"保险库已挂载"即可，解密内容就在映射到 `/mnt` 的宿主机目录里。

## 环境变量

| 变量 | 默认 | 说明 |
| --- | --- | --- |
| `VAULT_PASS` | | 保险库密码 |
| `VAULT_PASS_FILE` | | 密码文件路径（UTF-8），优先于 `VAULT_PASS` |
| `VAULT_PATH` | `/cryptonator-mount` | 容器内加密保险库路径 |
| `VAULT_MOUNT` | `/mnt` | 容器内解密挂载点 |
| `MOUNTER` | `fuse` | `fuse` 或 `webdav`（webdav 只监听 localhost，需 `network_mode: host`） |
| `MOUNT_OPTIONS` | | 额外 libfuse 参数，空格分隔，如 `-oallow_other` |
| `WEBDAV_PORT` | | webdav 模式端口 |
| `EXTRA_ARGS` | | 原样追加给 `cryptomator-cli unlock` |

`VAULT_NAME` 已不再使用，保留在 compose 里也不会出错。

## 群晖（DSM）注意事项

1. **共享挂载**：群晖默认不是 shared 挂载，容器用 `shared` 传播时会报 `is mounted on /volume1 but it is not a shared mount`。
   需要 root 执行 `mount --make-shared /volume1`，重启后会失效，请在"任务计划 → 开机"里加上。
2. **/dev/fuse**：SSH 登录后执行 `ls -l /dev/fuse`，应该能看到设备文件。不存在时需要先加载 FUSE 内核模块（因机型和 DSM 版本而异）。
3. **架构**：`uname -m` 为 `x86_64` 或 `aarch64` 都可以。旧版本镜像只有 amd64，在 ARM 机型上会报 `exec format error`。
4. **残留挂载**：容器被强制删除后，宿主机目录可能显示 `Transport endpoint is not connected`，
   执行 `sudo fusermount -uz /你的/解密目录`（或 `sudo umount -l`）后再启动。
5. **Immich 等读取方**：把读取解密目录的那个挂载改成 `rslave` 传播，并 `depends_on` 本容器的 `service_healthy`。

## 排查

- `docker logs cryptomator`：入口脚本会明确提示缺目录、缺 `vault.cryptomator`、缺密码、密码错误等。
- `docker inspect --format '{{.State.Health.Status}}' cryptomator`：`healthy` 表示 FUSE 已真正挂载。
