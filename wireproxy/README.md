> 项目地址：https://github.com/pufferffish/wireproxy

- 一键运行

```yaml
docker run -d --name wireproxy --net host --restart always -v /etc/wireproxy/wireproxy.conf:/etc/wireproxy/wireproxy.conf yujibuzailai/wireproxy:latest
```
- 重启

```yaml
docker restart wireproxy
```
