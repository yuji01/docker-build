## frps 服务端
```yaml
name: frps
services:
    frps:
        image: yujibuzailai/frps
        restart: always
        network_mode: "host"
        environment:
            "URL": "" # 配置文件下载直链
```

## frpc 客户端
```yaml
name: frpc
services:
    frpc:
        image: yujibuzailai/frpc
        restart: always
        network_mode: "host"
        environment:
            "URL": "" # 配置文件下载直链
```
