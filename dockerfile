# --- Builder Stage ---
FROM golang:alpine AS builder

# 设置工作目录
WORKDIR /app

# 明确声明要构建的 derper 版本，这个值可以由 docker build 命令通过 --build-arg 传入
# 如果不传入，默认为 'latest'
ARG DERP_VERSION=latest

# 设置 Go 环境变量，例如 GOPROXY（如果需要）
# RUN go env -w GOPROXY=https://goproxy.cn,direct

# 在构建前打印版本信息，方便调试
RUN echo "🚀 Building derper from tailscale.com@${DERP_VERSION}..."

# 构建静态链接的 derper 二进制文件
# CGO_ENABLED=0 确保静态链接，不依赖外部 C 库
# 注意：我们安装的是 tailscale.com 主模块下的 cmd/derper
RUN CGO_ENABLED=0 go install tailscale.com/cmd/derper@${DERP_VERSION}

# --- Final Stage ---
FROM alpine:latest

LABEL org.opencontainers.image.source="https://github.com/tailscale/tailscale" \
      org.opencontainers.image.description="Self-hosted DERP server for Tailscale"

WORKDIR /app

# 安装必要的 ca-certificates
RUN apk update && \
    apk add --no-cache ca-certificates && \
    rm -rf /var/cache/apk/*

# 创建证书存放目录
RUN mkdir -p /app/certs

# 从 builder 阶段复制编译好的 derper 二进制文件
COPY --from=builder /go/bin/derper /app/derper

# 复制 entrypoint 脚本并赋予执行权限
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# 设置默认环境变量 (用户可以在 docker run 或 docker-compose 中覆盖)
ENV DERP_DOMAIN="example.com" \
    DERP_CERT_MODE="letsencrypt" \
    DERP_CERT_DIR="/app/certs" \
    DERP_ADDR=":443" \
    DERP_STUN="true" \
    DERP_STUN_PORT="3478" \
    DERP_HTTP_PORT="80" \
    DERP_DERP="true" \
    DERP_VERIFY_CLIENTS="false"

# 暴露端口 (仅为文档目的)
EXPOSE 443/tcp
EXPOSE 80/tcp
EXPOSE 3478/udp

# 设置容器的入口点，它会执行脚本，脚本会处理环境变量并启动 derper
ENTRYPOINT ["/app/entrypoint.sh"]
