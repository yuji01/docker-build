# chevereto 开心版 docker 部署
**chevereto 0.4.7**

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

4. 启动容器

```bash
docker compose up -d
```

