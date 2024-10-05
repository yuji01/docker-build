> 项目地址：https://github.com/TeamPGM/PagerMaid-Pyro

- docker-compose.yml

```yaml
services:
  pagermaid:
    image: yujibuzailai/pagermaid_pyro:me
    restart: always
    container_name: pagermaid
    hostname: pagermaid
    ports:                 # 是否开启网页控制面板
      - "3333:3333"
    volumes:
      - './data:/pagermaid/workdir/data'
      - './proxychains.conf:/etc/proxychains4.conf:ro'
    environment:
      - WEB_ENABLE=true
      - WEB_SECRET_KEY=password
      - WEB_HOST=0.0.0.0
      - WEB_PORT=3333
```
