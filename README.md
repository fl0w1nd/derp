# derper
tailscale derper docker 镜像

## 使用方法

docker-compose 部署

```yaml
services:
  derper:
    image: fl0w1nd/derper:latest
    container_name: derper
    environment:
      - TZ=Asia/Shanghai
      - DERP_CERT_MODE=manual
      - DERP_DOMAIN=your hostname
      - DERP_ADDR=:12345
      - DERP_HTTP_PORT=-1
      - DERP_STUN_PORT=3478
      - DERP_VERIFY_CLIENTS=true
      - DERP_CERT_DIR=/app/certs
    volumes:
      - /var/run/tailscale:/var/run/tailscale
      - ./certs:/app/certs
    network_mode: host
    restart: always
```

| env                    | required | description                                                                 | default value     |
| -------------------    | -------- | ----------------------------------------------------------------------      | ----------------- |
| DERP_DOMAIN            | true     | derper server hostname                                                      | your-hostname.com |
| DERP_CERT_DIR          | false    | directory to store LetsEncrypt certs(if addr's port is :443)                | /app/certs        |
| DERP_CERT_MODE         | false    | mode for getting a cert. possible options: manual, letsencrypt              | letsencrypt       |
| DERP_ADDR              | false    | listening server address                                                    | :443              |
| DERP_STUN              | false    | also run a STUN server                                                      | true              |
| DERP_STUN_PORT         | false    | The UDP port on which to serve STUN.                                        | 3478              |
| DERP_HTTP_PORT         | false    | The port on which to serve HTTP. Set to -1 to disable                       | 80                |
| DERP_VERIFY_CLIENTS    | false    | verify clients to this DERP server through a local tailscaled instance      | false             |
| DERP_VERIFY_CLIENT_URL | false    | if non-empty, an admission controller URL for permitting client connections | ""                |

## ACL 配置

```json
	"derpMap": {
		"OmitDefaultRegions": true,
		"Regions": {
			"900": {
				"RegionID":   900,
				"RegionCode": "CN",
				"RegionName": "custum",
				"Nodes": [
					{
						"Name":             "derper",
						"RegionID":         900,
						"DERPPort":         12345,
						"HostName":         "your-hostname.com",
						"CertName":         "可在启动后 derper 的日志中查看",
						"InsecureForTests": true,
						"STUNPort":         3478,
					},
				],
			},
		},
	},
```

## 注意
- 如果使用自签名证书，需要将 DERP_CERT_MODE 设置为 manual
- DERP_DOMAIN 设置为 ip 可跳过 sni 验证
- 开启 DERP_VERIFY_CLIENTS 需要安装 tailscale 客户端并挂载 /var/run/tailscale
