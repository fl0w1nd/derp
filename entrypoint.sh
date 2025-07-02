#!/bin/sh
set -e

exec /app/derper \
     --hostname="$DERP_DOMAIN" \
     --certmode="$DERP_CERT_MODE" \
     --certdir="$DERP_CERT_DIR" \
     --a="$DERP_ADDR" \
     --stun="$DERP_STUN" \
     --stun-port="$DERP_STUN_PORT" \
     --http-port="$DERP_HTTP_PORT" \
     --verify-clients="$DERP_VERIFY_CLIENTS"
