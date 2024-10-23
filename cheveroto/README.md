# cheveretoChinaV4 版本docker部署
chevereto 4.0.7

> 镜像说明：
>
> - `yujibuzailai/chevereto:web` : 用于 php-fpm 的 web 镜像
> - `yujibuzailai/chevereto:china` : 包含了开心版的 php-fpm 镜像
> - 二者缺一不可

## 使用方法

---
1. 编写`compose.yml`

```yaml
name: chevereto
services:
    php-fpm: # 这个名字不要改
        image: yujibuzailai/chevereto:china
        restart: always
        container_name: chevereto-php-fpm
        env_file:
            - .env # 引用环境变量文件
        volumes:
            - './html:/var/www/html'
        networks:
            - chevereto
    web:
        image: yujibuzailai/chevereto:web
        restart: always
        container_name: chevereto-web
        networks:
            - chevereto
        ports:
            - '8080:80'
        volumes:
            - './html:/var/www/html'
        depends_on:
            - php-fpm

networks:
    chevereto:
        driver: bridge
```

2. 提取 html 到本地

```bash
container_id=$(docker create yujibuzailai/chevereto:china)
docker cp $container_id:/var/www/html/. ./html/
docker rm $container_id
```
3. 授权 html

```bash
chown www-data:www-data html -R
```

4. 编辑 `.env` 文件
- 没有配置过数据库，或者重新弄

```
CHEVERETO_HOSTNAME=img2.narutos.top # 要监听的路径，需要能直接访问
CHEVERETO_HTTPS=1 # 启用https填1，不启用填0
```

- 已经配置过数据库

```
CHEVERETO_DB_HOST=100.100.100.100
CHEVERETO_DB_NAME=cheveretochina
CHEVERETO_DB_PASS=62Nk4diri3rPkiY84ffDEaAN2hAp7cWC
CHEVERETO_DB_PORT=3306
CHEVERETO_DB_USER=cheveretochina
CHEVERETO_DB_TABLE_PREFIX=chv_
CHEVERETO_ENCRYPTION_KEY=4gHRSO20yIW3vTkn4slc46mhXVeRsxSIIBI0vLZ6/eo=
CHEVERETO_HOSTNAME=img2.narutos.top
CHEVERETO_HTTPS=1
```

4. 启动容器

```bash
docker compose up -d
```
## 查看环境变量

```sh
cat html/app/env.php
```

- 可以将这部分记录下来，以后迁移就方便了
