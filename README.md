# derper

Tailscale DERP 服务器 Docker 镜像

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
      - DERP_DOMAIN=your-domain.com
      - DERP_ADDR=:12345
      - DERP_HTTP_PORT=-1
      - DERP_STUN=true
      - DERP_STUN_PORT=3478
      - DERP_VERIFY_CLIENTS=true
      - DERP_CERT_DIR=/app/certs
    volumes:
      - /var/run/tailscale:/var/run/tailscale
      - ./certs:/app/certs
    network_mode: host
    restart: always
```

## 环境变量

所有参数均通过环境变量配置。分为**基础参数**（始终生效，有默认值）和**可选参数**（仅在设置时传递给 derper，否则使用 derper 内置默认值）。

### 基础参数

| 环境变量 | 说明 | 默认值 |
|---------|------|--------|
| `DERP_DOMAIN` | **（必填）** DERP 服务器的主机名，用于 TLS 证书。当 `DERP_CERT_MODE=manual` 时可设为 IP 地址以跳过 SNI 验证 | `example.com` |
| `DERP_CERT_MODE` | 证书获取方式：`letsencrypt`（自动申请 Let's Encrypt 证书）、`manual`（使用自签名或手动管理的证书）、`gcp`（通过 GCP 获取证书） | `letsencrypt` |
| `DERP_CERT_DIR` | 证书存储目录，使用 Let's Encrypt 时用于存放自动申请的证书，使用 manual 模式时存放你提供的证书文件 | `/app/certs` |
| `DERP_ADDR` | 服务监听地址，格式为 `:port`、`ip:port` 或 `[ip]:port`。端口为 443 时自动启用 HTTPS | `:443` |
| `DERP_STUN` | 是否同时运行 STUN 服务器，STUN 用于帮助客户端探测 NAT 类型以实现直连 | `true` |
| `DERP_STUN_PORT` | STUN 服务监听的 UDP 端口 | `3478` |
| `DERP_HTTP_PORT` | HTTP 服务端口，用于 Let's Encrypt 验证或提供 HTTP 访问。设为 `-1` 可禁用 | `80` |
| `DERP_DERP` | 是否运行 DERP 中继服务。设为 `false` 可在退役节点时仅保留 STUN 和 Bootstrap DNS 功能 | `true` |
| `DERP_VERIFY_CLIENTS` | 是否通过本地 tailscaled 实例验证客户端身份，开启后仅允许你网络中的设备连接。需挂载 `/var/run/tailscale` | `false` |

### 客户端验证（可选）

| 环境变量 | 说明 | 默认值 |
|---------|------|--------|
| `DERP_VERIFY_CLIENT_URL` | 准入控制器 URL，用于自定义客户端连接审批逻辑。设置后 derper 会在客户端连接时向该 URL 发送请求进行鉴权 | 不设置 |
| `DERP_VERIFY_CLIENT_URL_FAIL_OPEN` | 当准入控制器不可达时是否放行连接。`true` 表示放行（fail-open），`false` 表示拒绝（fail-close） | derper 默认 `true` |
| `DERP_SOCKET` | tailscaled 的 Unix socket 路径，仅在 `DERP_VERIFY_CLIENTS=true` 且 socket 路径非默认时需要设置 | 不设置 |

### 速率限制（可选）

| 环境变量 | 说明 | 默认值 |
|---------|------|--------|
| `DERP_ACCEPT_CONNECTION_LIMIT` | 新连接的速率限制，单位为 连接数/秒。可用于防止恶意扫描或暴力连接 | derper 默认无限制 |
| `DERP_ACCEPT_CONNECTION_BURST` | 新连接的突发上限，配合速率限制使用。允许短时间内超出速率限制的最大连接数 | derper 默认无限制 |

### TCP 调优（可选）

| 环境变量 | 说明 | 默认值 |
|---------|------|--------|
| `DERP_TCP_KEEPALIVE_TIME` | TCP keepalive 探测间隔，格式为 Go duration（如 `10m`、`30s`）。derper 默认较长以节省移动设备电量 | derper 默认 `10m` |
| `DERP_TCP_USER_TIMEOUT` | TCP 用户超时时间，用于检测挂起的连接。设置较短的值可更快清理异常断开的连接 | derper 默认 `15s` |
| `DERP_TCP_WRITE_TIMEOUT` | TCP 写超时时间，仅作用于客户端连接（不影响 mesh 连接）。设为 `0` 可禁用 | derper 默认值 |

### 服务器配置（可选）

| 环境变量 | 说明 | 默认值 |
|---------|------|--------|
| `DERP_HOME` | 根路径 `/` 的展示内容。留空显示默认首页，设为 `blank` 显示空白页，或设为 URL 进行跳转 | 不设置 |
| `DERP_CONFIG` | 服务器私钥配置文件路径。derper 会在此文件中存储自动生成的节点私钥 | derper 默认 `/var/lib/derper/derper.key` |

### Mesh 组网（可选）

| 环境变量 | 说明 | 默认值 |
|---------|------|--------|
| `DERP_MESH_PSK_FILE` | Mesh 预共享密钥文件路径，文件内容为 64 位小写十六进制字符。多个 DERP 节点之间通过此密钥互相认证 | 不设置 |
| `DERP_MESH_WITH` | 要组网的 DERP 节点主机名列表，逗号分隔。配置后多个 DERP 节点之间会互相转发流量 | 不设置 |

> **提示**：Mesh 组网功能主要用于部署多个 DERP 节点的场景，单节点部署无需配置。

## ACL 配置

在 Tailscale 管理后台的 ACL 中添加自定义 DERP 节点：

```json
"derpMap": {
    "OmitDefaultRegions": true,
    "Regions": {
        "900": {
            "RegionID":   900,
            "RegionCode": "CN",
            "RegionName": "custom",
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

- 如果使用自签名证书，需要将 `DERP_CERT_MODE` 设置为 `manual`
- `DERP_DOMAIN` 设置为 IP 地址可跳过 SNI 验证
- 开启 `DERP_VERIFY_CLIENTS` 需要在宿主机安装 Tailscale 客户端并挂载 `/var/run/tailscale`
