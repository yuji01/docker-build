```sh
docker run -d --name kms --restart always -p 1688:1688 yujibuzailai/kms
```

- 查询 kms 是否运行

```sh
docker run --rm --network host yujibuzailai/kms vlmcs kms.narutos.top:1688
```
