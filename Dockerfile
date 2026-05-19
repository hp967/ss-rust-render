# ================================
# SS-Rust Render — 多阶段构建
# 阶段 1：在容器内编译 shadowsocks-rust（生成匹配 Render amd64 的二进制）
# 阶段 2：极小 Alpine 运行镜像
# ================================

# ---------- 构建阶段 ----------
FROM rust:1.78-slim AS builder

RUN apt-get update && \
    apt-get install -y --no-install-recommends pkg-config libssl-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 拉取 shadowsocks-rust 稳定版源码
RUN git clone --depth 1 --branch v1.21.2 \
    https://github.com/shadowsocks/shadowsocks-rust.git . && \
    cargo build --release

# ---------- 运行阶段 ----------
FROM alpine:3.21

RUN apk add --no-cache ca-certificates bash && \
    update-ca-certificates

COPY --from=builder /app/target/release/ssserver /usr/local/bin/ssserver
RUN ln -s /usr/local/bin/ssserver /usr/local/bin/shadowsocks-server && \
    chmod +x /usr/local/bin/ssserver /usr/local/bin/shadowsocks-server && \
    ls -la /usr/local/bin/ && \
    file /usr/local/bin/ssserver && \
    /usr/local/bin/ssserver --version

ENV PATH="/usr/local/bin:${PATH}"
ENV SS_SERVER_PORT=8388 \
    SS_METHOD=aes-256-gcm

EXPOSE 8388

# 健康检查（TCP 服务，exit 0 即可）
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD exit 0

# 使用 shell 格式确保 ${} 环境变量被展开
CMD /usr/local/bin/ssserver \
    -s "0.0.0.0:${SS_SERVER_PORT}" \
    -k "${SS_PASSWORD}" \
    -m "${SS_METHOD}"
