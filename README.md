# derper

[简体中文](README_CN.md)

Tailscale DERP Server Docker Image

---

## Usage

Deploy with docker-compose:

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

## Environment Variables

All parameters are configured via environment variables. They are divided into **basic parameters** (always effective with default values) and **optional parameters** (only passed to derper when set; otherwise derper's built-in defaults are used).

### Basic Parameters

| Env Var | Description | Default |
|---------|-------------|---------|
| `DERP_DOMAIN` | **(Required)** Hostname for the DERP server, used for TLS certificates. Can be set to an IP address to skip SNI verification when `DERP_CERT_MODE=manual`. | `example.com` |
| `DERP_CERT_MODE` | Certificate mode: `letsencrypt` (automatic), `manual` (self-managed), or `gcp` (via GCP). | `letsencrypt` |
| `DERP_CERT_DIR` | Certificate storage directory. | `/app/certs` |
| `DERP_ADDR` | Listen address in `:port`, `ip:port`, or `[ip]:port` format. HTTPS is enabled automatically when port is 443. | `:443` |
| `DERP_STUN` | Whether to run a STUN server alongside DERP for NAT traversal. | `true` |
| `DERP_STUN_PORT` | UDP port for the STUN server. | `3478` |
| `DERP_HTTP_PORT` | HTTP port. Set to `-1` to disable. | `80` |
| `DERP_DERP` | Whether to run the DERP relay. Set to `false` to keep only STUN and Bootstrap DNS. | `true` |
| `DERP_VERIFY_CLIENTS` | Verify client identity via local tailscaled. Requires mounting `/var/run/tailscale`. | `false` |

### Client Verification (Optional)

| Env Var | Description | Default |
|---------|-------------|---------|
| `DERP_VERIFY_CLIENT_URL` | Admission controller URL for custom client connection approval. | Unset |
| `DERP_VERIFY_CLIENT_URL_FAIL_OPEN` | Whether to allow connections when the admission controller is unreachable. `true` = fail-open, `false` = fail-close. | derper default `true` |
| `DERP_SOCKET` | Unix socket path for tailscaled. Only needed when `DERP_VERIFY_CLIENTS=true` and the path is non-default. | Unset |

### Rate Limiting (Optional)

| Env Var | Description | Default |
|---------|-------------|---------|
| `DERP_ACCEPT_CONNECTION_LIMIT` | Rate limit for new connections (connections/sec). | Unlimited |
| `DERP_ACCEPT_CONNECTION_BURST` | Burst limit for new connections, used with rate limiting. | Unlimited |

### TCP Tuning (Optional)

| Env Var | Description | Default |
|---------|-------------|---------|
| `DERP_TCP_KEEPALIVE_TIME` | TCP keepalive interval (Go duration format, e.g. `10m`). | derper default `10m` |
| `DERP_TCP_USER_TIMEOUT` | TCP user timeout for detecting hung connections. | derper default `15s` |
| `DERP_TCP_WRITE_TIMEOUT` | TCP write timeout for client connections only. Set to `0` to disable. | derper default |

### Server Configuration (Optional)

| Env Var | Description | Default |
|---------|-------------|---------|
| `DERP_HOME` | Content for root path `/`. Empty for default homepage, `blank` for blank page, or a URL to redirect. | Unset |
| `DERP_CONFIG` | Server private key configuration file path. | derper default `/var/lib/derper/derper.key` |

### Mesh Networking (Optional)

| Env Var | Description | Default |
|---------|-------------|---------|
| `DERP_MESH_PSK_FILE` | Path to mesh pre-shared key file (64 lowercase hex characters). | Unset |
| `DERP_MESH_WITH` | Comma-separated list of DERP node hostnames to mesh with. | Unset |

> **Note**: Mesh networking is mainly for multi-node deployments; not needed for single-node setups.

## ACL Configuration

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
                    "CertName":         "Check derper logs after startup",
                    "InsecureForTests": true,
                    "STUNPort":         3478,
                },
            ],
        },
    },
},
```

## Notes

- If using self-signed certificates, set `DERP_CERT_MODE` to `manual`.
- Setting `DERP_DOMAIN` to an IP address skips SNI verification.
- Enabling `DERP_VERIFY_CLIENTS` requires Tailscale installed on the host and mounting `/var/run/tailscale`.