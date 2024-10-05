> 项目地址：https://github.com/TeamPGM/PagerMaid-Pyro

- docker-compose.yml

```yaml
services:
    pagermaid:
        image: yujibuzailai/pagermaid_pyro:me
        restart: always
        container_name: pagermaid
        hostname: pagermaid
        ports:                                 # 是否开启网页控制面板
            - "800:80"
        volumes:
            - './data:/pagermaid/workdir/data'
            - './plugins:/pagermaid/workdir/plugins'
            - './proxychains.conf:/etc/proxychains4.conf:ro'
        environment:
            - WEB_ENABLE=true
            - WEB_SECRET_KEY=passwd
            - WEB_HOST=0.0.0.0
            - WEB_PORT=80
```

```shell
docker-compose run --rm -it -p 800:80 pagermaid
```
