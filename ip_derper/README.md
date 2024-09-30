# ip-derper

1. build

```
docker build --no-cache -t yujibuzailai/ip_derper .
```

2. run

```
docker run --rm -d -p 50443:443 -p 3478:3478/udp yujibuzailai/ip_derper
```

3. modify tailscale ACLs

inserts this into tailscale ACLs: https://login.tailscale.com/admin/acls
```json

	// 自定义配置开始
	"derpMap": {
		//"OmitDefaultRegions": true, //禁用其他中转服务器
		"Regions": {
			"1": null, //纽约-美国
			"2": null, //旧金山-美国
			//"3":  null, //新加坡
			"4": null, //法兰克福-德国
			"5": null, //悉尼-澳大利亚
			"6": null, //班加罗尔-印度
			//"7":  null, //东京-日本
			"8":  null, //伦敦-英国
			"9":  null, //达拉斯-美国
			"10": null, //西雅图-美国
			"11": null, //圣保罗-巴西
			"12": null, //芝加哥-美国
			"13": null, //丹佛-美国
			"14": null, //阿姆斯特丹-荷兰
			"15": null, //約翰尼斯堡-南非
			"16": null, //迈阿密-美国
			//"17": null, //洛杉矶-美国
			"18": null, //巴黎-法国
			"19": null, //马德里-西班牙
			//"20": null, //香港不禁用
			"21": null, //多伦多-加拿大
			"22": null, //华沙-波兰
			"23": null, //杜拜-阿联酋
			"24": null, //檀香山-美国
			"25": null, //奈洛比-肯尼亚
			"901": {
				"RegionID":   901,
				"RegionCode": "Myself",
				"RegionName": "Myself Derper",
				"Nodes": [
					{
						"Name":             "901a",
						"RegionID":         901,
						"DERPPort":         50443, //服务器的端口
						"IPv4":             "00000", //服务器的IP
						"InsecureForTests": true,
					},
				],
			},
		},
	},
	// 自定义配置结束
	// Define users and devices that can use Tailscale SSH.
	"ssh": [


```

enjoy :)

1. 下载并修改
```
git clone https://github.com/yuji01/ip_derper.git
cd ip_derper
git clone https://github.com/tailscale/tailscale.git tailscale --depth 1
```
2. 找到 tailscale 仓库中的 cmd/derper/cert.go 文件，将与域名验证相关的内容删除或注释：

```
...
func (m *manualCertManager) getCertificate(hi *tls.ClientHelloInfo) (*tls.Certificate, error) {
	//if hi.ServerName != m.hostname {
	//	return nil, fmt.Errorf("cert mismatch with hostname: %q", hi.ServerName)
	//}
	return m.cert, nil
}
...
```
3. 编译
```
docker build --no-cache -t yujibuzailai/ip_derper .
```
