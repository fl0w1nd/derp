# --- Builder Stage ---
FROM golang:1.22-alpine AS builder

WORKDIR /app

# 设置 Go 环境变量，例如 GOPROXY（如果需要）
# RUN go env -w GOPROXY=https://goproxy.cn,direct

# 使用 Docker 内置的平台变量来确保正确的架构构建
ARG TARGETPLATFORM
ARG TARGETOS
ARG TARGETARCH
ARG DERP_VERSION=latest

# 构建静态链接的 derper 二进制文件
# CGO_ENABLED=0 确保静态链接，不依赖外部 C 库
# 使用 TARGETOS 和 TARGETARCH 来构建正确的架构
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go install tailscale.com/cmd/derper@${DERP_VERSION}

# --- Final Stage ---
FROM alpine:latest

WORKDIR /app

# 安装必要的 ca-certificates
# tzdata 用于时区设置 (如果需要，但 derper 本身可能不直接使用)
RUN apk update && \
    apk add --no-cache ca-certificates tzdata && \
    rm -rf /var/cache/apk/*

# 创建证书存放目录 (如果使用 derper 的证书功能)
RUN mkdir -p /app/certs

# 从 builder 阶段复制编译好的 derper 二进制文件
COPY --from=builder /go/bin/derper /app/derper

# 设置环境变量
ENV DERP_DOMAIN=your-hostname.com \
    DERP_CERT_MODE=letsencrypt \
    DERP_CERT_DIR=/app/certs \
    DERP_ADDR=:443 \
    DERP_STUN=true \
    DERP_STUN_PORT=3478 \
    DERP_HTTP_PORT=80 \
    DERP_VERIFY_CLIENTS=false \
    DERP_VERIFY_CLIENT_URL=""

# 暴露端口 (仅为文档目的，实际端口映射在 docker-compose 中定义)
EXPOSE 443/tcp
EXPOSE 80/tcp
EXPOSE 3478/udp

# 容器启动命令
CMD /app/derper --hostname=$DERP_DOMAIN \
    --certmode=$DERP_CERT_MODE \
    --certdir=$DERP_CERT_DIR \
    --a=$DERP_ADDR \
    --stun=$DERP_STUN \
    --stun-port=$DERP_STUN_PORT \
    --http-port=$DERP_HTTP_PORT \
    --verify-clients=$DERP_VERIFY_CLIENTS \
    --verify-client-url=$DERP_VERIFY_CLIENT_URL
    