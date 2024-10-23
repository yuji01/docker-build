# cheveretoChinaV4 版本docker部署
chevereto 0.4.7
## 镜像说明：
- `yujibuzailai/chevereto:web` : 用于 php-fpm 的 web 镜像
- `yujibuzailai/chevereto:china` : 包含了开心版的 php-fpm 镜像
> 二者缺一不可
---
## compose.yml
```yaml
name: chevereto
services:
    php-fpm: # 这个名字不要改
        image: yujibuzailai/chevereto:china
        volumes:
            - './html:/var/www/html'
        networks:
            - chevereto
    web:
        image: yujibuzailai/chevereto:web
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

## 提取html到本地
```bash
container_id=$(docker create yujibuzailai/chevereto:china)
docker cp $container_id:/var/www/html/. ./html/
docker rm $container_id
```
## 授权
```bash
chown www-data:www-data html -R
```
