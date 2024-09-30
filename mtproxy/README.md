# mtproxy说明

> 项目地址：https://github.com/ellermister/mtproxy

- 为什么容器是8443？

答：容器里存在两个监控端口的程序，一个是nginx（80，443），另一个是mtproxy（8080，8443）
实际上是用nginx进行了反向代理，所以应该用443
