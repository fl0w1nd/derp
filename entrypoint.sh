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

exec $CMD
