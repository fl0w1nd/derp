#!/bin/sh
set -e

CMD="/app/derper \
     --hostname=$DERP_DOMAIN \
     --certmode=$DERP_CERT_MODE \
     --certdir=$DERP_CERT_DIR \
     --a=$DERP_ADDR \
     --stun=$DERP_STUN \
     --stun-port=$DERP_STUN_PORT \
     --http-port=$DERP_HTTP_PORT \
     --derp=$DERP_DERP \
     --verify-clients=$DERP_VERIFY_CLIENTS"

# 以下为可选参数，仅在设置时传递，否则使用 derper 内置默认值

[ -n "$DERP_HOME" ] && CMD="$CMD --home=$DERP_HOME"
[ -n "$DERP_CONFIG" ] && CMD="$CMD --c=$DERP_CONFIG"

[ -n "$DERP_VERIFY_CLIENT_URL" ] && CMD="$CMD --verify-client-url=$DERP_VERIFY_CLIENT_URL"
[ -n "$DERP_VERIFY_CLIENT_URL_FAIL_OPEN" ] && CMD="$CMD --verify-client-url-fail-open=$DERP_VERIFY_CLIENT_URL_FAIL_OPEN"
[ -n "$DERP_SOCKET" ] && CMD="$CMD --socket=$DERP_SOCKET"

[ -n "$DERP_ACCEPT_CONNECTION_LIMIT" ] && CMD="$CMD --accept-connection-limit=$DERP_ACCEPT_CONNECTION_LIMIT"
[ -n "$DERP_ACCEPT_CONNECTION_BURST" ] && CMD="$CMD --accept-connection-burst=$DERP_ACCEPT_CONNECTION_BURST"

[ -n "$DERP_TCP_KEEPALIVE_TIME" ] && CMD="$CMD --tcp-keepalive-time=$DERP_TCP_KEEPALIVE_TIME"
[ -n "$DERP_TCP_USER_TIMEOUT" ] && CMD="$CMD --tcp-user-timeout=$DERP_TCP_USER_TIMEOUT"
[ -n "$DERP_TCP_WRITE_TIMEOUT" ] && CMD="$CMD --tcp-write-timeout=$DERP_TCP_WRITE_TIMEOUT"

[ -n "$DERP_MESH_PSK_FILE" ] && CMD="$CMD --mesh-psk-file=$DERP_MESH_PSK_FILE"
[ -n "$DERP_MESH_WITH" ] && CMD="$CMD --mesh-with=$DERP_MESH_WITH"

# ACME / 证书相关（可选）
[ -n "$DERP_ACME_EMAIL" ] && CMD="$CMD --acme-email=$DERP_ACME_EMAIL"
[ -n "$DERP_ACME_EAB_KID" ] && CMD="$CMD --acme-eab-kid=$DERP_ACME_EAB_KID"
[ -n "$DERP_ACME_EAB_KEY" ] && CMD="$CMD --acme-eab-key=$DERP_ACME_EAB_KEY"
[ -n "$DERP_ACME_IP_CERTS" ] && CMD="$CMD --acme-ip-certs=$DERP_ACME_IP_CERTS"

# Bootstrap DNS（可选）
[ -n "$DERP_BOOTSTRAP_DNS_NAMES" ] && CMD="$CMD --bootstrap-dns-names=$DERP_BOOTSTRAP_DNS_NAMES"
[ -n "$DERP_UNPUBLISHED_BOOTSTRAP_DNS_NAMES" ] && CMD="$CMD --unpublished-bootstrap-dns-names=$DERP_UNPUBLISHED_BOOTSTRAP_DNS_NAMES"

# 速率限制配置文件（可选，实验性，SIGHUP 重载）
[ -n "$DERP_RATE_CONFIG" ] && CMD="$CMD --rate-config=$DERP_RATE_CONFIG"

# SETEC secrets（可选，主要用于 Tailscale 内部 mesh key 获取）
[ -n "$DERP_SECRETS_URL" ] && CMD="$CMD --secrets-url=$DERP_SECRETS_URL"
[ -n "$DERP_SECRETS_PATH_PREFIX" ] && CMD="$CMD --secrets-path-prefix=$DERP_SECRETS_PATH_PREFIX"
[ -n "$DERP_SECRETS_CACHE_DIR" ] && CMD="$CMD --secrets-cache-dir=$DERP_SECRETS_CACHE_DIR"

# 开发与实验性（一般无需设置）
[ -n "$DERP_DEV" ] && CMD="$CMD --dev=$DERP_DEV"
[ -n "$DERP_PRINT_VERSION" ] && CMD="$CMD --version=$DERP_PRINT_VERSION"
[ -n "$DERP_ACE" ] && CMD="$CMD --ace=$DERP_ACE"

exec $CMD
