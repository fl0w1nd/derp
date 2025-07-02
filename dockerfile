# --- Builder Stage ---
# 使用更具体的 Go 版本以保证构建环境的稳定性
FROM golang:alpine AS builder

# 设置工作目录
WORKDIR /app

# 明确声明要构建的 derper 版本，这个值可以由 docker build 命令通过 --build-arg 传入
# 如果不传入，默认为 'latest'
ARG DERP_VERSION=latest

# 使用 Docker 内置的平台变量来确保正确的架构构建
ARG TARGETPLATFORM
ARG TARGETOS
ARG TARGETARCH

# 设置 Go 环境变量，例如 GOPROXY（如果需要）
# RUN go env -w GOPROXY=https://goproxy.cn,direct

# 在构建前打印版本信息，方便调试
RUN echo "🚀 Building derper from tailscale.com@${DERP_VERSION} for ${TARGETPLATFORM}..."

# 构建静态链接的 derper 二进制文件
# CGO_ENABLED=0 确保静态链接，不依赖外部 C 库
# 使用 TARGETOS 和 TARGETARCH 来构建正确的架构
# 注意：我们安装的是 tailscale.com 主模块下的 cmd/derper
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
    go install tailscale.com/cmd/derper@${DERP_VERSION}

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

# 从 builder 阶段复制编译好的 derper 二进制文件和 Go 的二进制目录
COPY --from=builder /go/bin/derper /app/derper

# 设置默认环境变量 (用户可以在 docker run 或 docker-compose 中覆盖)
ENV DERP_DOMAIN="example.com" \
    DERP_CERT_MODE="letsencrypt" \
    DERP_CERT_DIR="/app/certs" \
    DERP_ADDR=":443" \
    DERP_STUN="true" \
    DERP_STUN_PORT="3478" \
    DERP_HTTP_PORT="80" \
    DERP_VERIFY_CLIENTS="false"

# 暴露端口 (仅为文档目的)
EXPOSE 443/tcp
EXPOSE 80/tcp
EXPOSE 3478/udp

# 容器启动命令
CMD ["/app/derper", \
     "--hostname=${DERP_DOMAIN}", \
     "--certmode=${DERP_CERT_MODE}", \
     "--certdir=${DERP_CERT_DIR}", \
     "--a=${DERP_ADDR}", \
     "--stun=${DERP_STUN}", \
     "--stun-port=${DERP_STUN_PORT}", \
     "--http-port=${DERP_HTTP_PORT}", \
     "--verify-clients=${DERP_VERIFY_CLIENTS}"]
