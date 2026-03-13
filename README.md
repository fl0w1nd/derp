# derper

Tailscale DERP 服务器 Docker 镜像 | Tailscale DERP Server Docker Image

---

## 使用方法 | Usage

docker-compose 部署 | Deploy with docker-compose

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

## 环境变量 | Environment Variables

所有参数均通过环境变量配置。分为**基础参数**（始终生效，有默认值）和**可选参数**（仅在设置时传递给 derper，否则使用 derper 内置默认值）。

All parameters are configured via environment variables. They are divided into **basic parameters** (always effective with default values) and **optional parameters** (only passed to derper when set; otherwise derper's built-in defaults are used).

### 基础参数 | Basic Parameters

| 环境变量 Env Var | 说明 Description | 默认值 Default |
|---------|------|--------|
| `DERP_DOMAIN` | **（必填 Required）** DERP 服务器的主机名，用于 TLS 证书。当 `DERP_CERT_MODE=manual` 时可设为 IP 地址以跳过 SNI 验证。<br>Hostname for the DERP server, used for TLS certificates. Can be set to an IP address to skip SNI verification when `DERP_CERT_MODE=manual`. | `example.com` |
| `DERP_CERT_MODE` | 证书获取方式：`letsencrypt`（自动申请）、`manual`（手动管理）、`gcp`（通过 GCP 获取）。<br>Certificate mode: `letsencrypt` (automatic), `manual` (self-managed), or `gcp` (via GCP). | `letsencrypt` |
| `DERP_CERT_DIR` | 证书存储目录。<br>Certificate storage directory. | `/app/certs` |
| `DERP_ADDR` | 服务监听地址，格式为 `:port`、`ip:port` 或 `[ip]:port`。端口为 443 时自动启用 HTTPS。<br>Listen address in `:port`, `ip:port`, or `[ip]:port` format. HTTPS is enabled automatically when port is 443. | `:443` |
| `DERP_STUN` | 是否同时运行 STUN 服务器，用于帮助客户端探测 NAT 类型。<br>Whether to run a STUN server alongside DERP for NAT traversal. | `true` |
| `DERP_STUN_PORT` | STUN 服务监听的 UDP 端口。<br>UDP port for the STUN server. | `3478` |
| `DERP_HTTP_PORT` | HTTP 服务端口，设为 `-1` 可禁用。<br>HTTP port. Set to `-1` to disable. | `80` |
| `DERP_DERP` | 是否运行 DERP 中继服务。设为 `false` 可仅保留 STUN 和 Bootstrap DNS 功能。<br>Whether to run the DERP relay. Set to `false` to keep only STUN and Bootstrap DNS. | `true` |
| `DERP_VERIFY_CLIENTS` | 是否通过本地 tailscaled 验证客户端身份。需挂载 `/var/run/tailscale`。<br>Verify client identity via local tailscaled. Requires mounting `/var/run/tailscale`. | `false` |

### 客户端验证（可选）| Client Verification (Optional)

| 环境变量 Env Var | 说明 Description | 默认值 Default |
|---------|------|--------|
| `DERP_VERIFY_CLIENT_URL` | 准入控制器 URL，用于自定义客户端连接审批逻辑。<br>Admission controller URL for custom client connection approval. | 不设置 Unset |
| `DERP_VERIFY_CLIENT_URL_FAIL_OPEN` | 准入控制器不可达时是否放行。`true` 放行，`false` 拒绝。<br>Whether to allow connections when the admission controller is unreachable. `true` = fail-open, `false` = fail-close. | derper 默认 default `true` |
| `DERP_SOCKET` | tailscaled 的 Unix socket 路径，仅在 `DERP_VERIFY_CLIENTS=true` 且路径非默认时需要。<br>Unix socket path for tailscaled. Only needed when `DERP_VERIFY_CLIENTS=true` and the path is non-default. | 不设置 Unset |

### 速率限制（可选）| Rate Limiting (Optional)

| 环境变量 Env Var | 说明 Description | 默认值 Default |
|---------|------|--------|
| `DERP_ACCEPT_CONNECTION_LIMIT` | 新连接速率限制（连接数/秒）。<br>Rate limit for new connections (connections/sec). | derper 默认无限制 default unlimited |
| `DERP_ACCEPT_CONNECTION_BURST` | 新连接突发上限，配合速率限制使用。<br>Burst limit for new connections, used with rate limiting. | derper 默认无限制 default unlimited |

### TCP 调优（可选）| TCP Tuning (Optional)

| 环境变量 Env Var | 说明 Description | 默认值 Default |
|---------|------|--------|
| `DERP_TCP_KEEPALIVE_TIME` | TCP keepalive 探测间隔（Go duration 格式）。<br>TCP keepalive interval (Go duration format, e.g. `10m`). | derper 默认 default `10m` |
| `DERP_TCP_USER_TIMEOUT` | TCP 用户超时时间，用于检测挂起连接。<br>TCP user timeout for detecting hung connections. | derper 默认 default `15s` |
| `DERP_TCP_WRITE_TIMEOUT` | TCP 写超时，仅作用于客户端连接。设为 `0` 可禁用。<br>TCP write timeout for client connections only. Set to `0` to disable. | derper 默认值 default |

### 服务器配置（可选）| Server Configuration (Optional)

| 环境变量 Env Var | 说明 Description | 默认值 Default |
|---------|------|--------|
| `DERP_HOME` | 根路径 `/` 的展示内容。留空显示默认首页，`blank` 显示空白页，或设为 URL 跳转。<br>Content for root path `/`. Empty for default homepage, `blank` for blank page, or a URL to redirect. | 不设置 Unset |
| `DERP_CONFIG` | 服务器私钥配置文件路径。<br>Server private key configuration file path. | derper 默认 default `/var/lib/derper/derper.key` |

### Mesh 组网（可选）| Mesh Networking (Optional)

| 环境变量 Env Var | 说明 Description | 默认值 Default |
|---------|------|--------|
| `DERP_MESH_PSK_FILE` | Mesh 预共享密钥文件路径（64 位小写十六进制）。<br>Path to mesh pre-shared key file (64 lowercase hex characters). | 不设置 Unset |
| `DERP_MESH_WITH` | 要组网的 DERP 节点主机名列表，逗号分隔。<br>Comma-separated list of DERP node hostnames to mesh with. | 不设置 Unset |

> **提示 | Note**：Mesh 组网功能主要用于多 DERP 节点场景，单节点无需配置。Mesh networking is mainly for multi-node deployments; not needed for single-node setups.

## ACL 配置 | ACL Configuration

在 Tailscale 管理后台的 ACL 中添加自定义 DERP 节点：

Add custom DERP nodes in Tailscale admin console ACL:

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
                    "CertName":         "Check derper logs after startup | 可在启动后 derper 的日志中查看",
                    "InsecureForTests": true,
                    "STUNPort":         3478,
                },
            ],
        },
    },
},
```

## 注意 | Notes

- 如果使用自签名证书，需要将 `DERP_CERT_MODE` 设置为 `manual`。
  If using self-signed certificates, set `DERP_CERT_MODE` to `manual`.
- `DERP_DOMAIN` 设置为 IP 地址可跳过 SNI 验证。
  Setting `DERP_DOMAIN` to an IP address skips SNI verification.
- 开启 `DERP_VERIFY_CLIENTS` 需要在宿主机安装 Tailscale 客户端并挂载 `/var/run/tailscale`。
  Enabling `DERP_VERIFY_CLIENTS` requires Tailscale installed on the host and mounting `/var/run/tailscale`.
