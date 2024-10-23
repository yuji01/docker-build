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
    php-fpm:
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
