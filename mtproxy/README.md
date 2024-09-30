# mtproxy说明

> 项目地址：https://github.com/ellermister/mtproxy

- 为什么容器是8443？

答：容器里存在两个监控端口的程序，一个是nginx（80，443），另一个是mtproxy（8080，8443）

**这个实际上是用nginx进行了反向代理mtproxy，所以应该用443**

```yaml
        ports:
            - 443:443 # 右边端口是443
```

- 如何自定义secret？

**程序每次运行会自动生成secret，需要在环境变量里添加**

```shell
secret=$(head -c 16 /dev/urandom | xxd -ps)
echo "$secret"
```
```yaml
        environment:
            - secret=548593a9c0688f4f7d9d57377897d964 # 填写自己的
```
