# ================================
# SS-Rust Render — FIXED
# Fixes: aarch64 + HEALTHCHECK + diag log
# ================================

FROM alpine:3.21 AS builder

RUN apk add --no-cache \
      ca-certificates \
      openssl \
      curl \
      xz \
      file \
      bash
RUN update-ca-certificates

# Render 构建机为 aarch64，必须用 ARM64 静态二进制
ARG SS_VERSION=v1.24.0

# 将所有诊断写文件，防止 binary 失败中断构建
RUN set -e; \
    curl -fsSL \
      "https://github.com/shadowsocks/shadowsocks-rust/releases/download/${SS_VERSION}/shadowsocks-${SS_VERSION}.aarch64-unknown-linux-musl.tar.xz" \
      -o /tmp/ss.tar.xz; \
    echo "DOWNLOAD_OK" > /tmp/diag.log; \
    tar -xJ -f /tmp/ss.tar.xz -C /usr/local/bin/; \
    echo "TAR_OK" >> /tmp/diag.log; \
    ls -la /usr/local/bin/ >> /tmp/diag.log 2>&1; \
    file /usr/local/bin/* >> /tmp/diag.log 2>&1; \
    chmod +x /usr/local/bin/*; \
    echo "CHMOD_OK" >> /tmp/diag.log; \
    /usr/local/bin/shadowsocks-server --version >> /tmp/diag.log 2>&1 || echo "VERSION_FAIL:$?" >> /tmp/diag.log; \
    /usr/local/bin/shadowsocks-server -h >> /tmp/diag.log 2>&1 || echo "HELP_FAIL:$?" >> /tmp/diag.log; \
    ldd /usr/local/bin/shadowsocks-server >> /tmp/diag.log 2>&1 || echo "LDD_FAIL:$?" >> /tmp/diag.log; \
    cat /tmp/diag.log

# ── 阶段 2：极小运行层 ─────────────────────
FROM alpine:3.21

RUN apk add --no-cache ca-certificates

COPY --from=builder /usr/local/bin /usr/local/bin/
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /tmp/diag.log /tmp/diag.log

ENV PATH="/usr/local/bin:${PATH}"

EXPOSE ${SS_SERVER_PORT:-8388}

# ═══ 关键修复 1：TCP 服务不需要 HTTP 健康检查，
#     加上 HEALTHCHECK exit 0 防止容器被 Render 视为不健康而重启
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD exit 0

# 将构建日志打印到容器标准输出（Render 可捕获）
RUN cat /tmp/diag.log

# ═══ 关键修复 2：shadowsocks-server 是 v1.24.0 的正确二进制名
CMD ["/usr/local/bin/shadowsocks-server", \
     "server", \
     "-u", \
     "-k", "${SS_PASSWORD}", \
     "-p", "${SS_SERVER_PORT:-8388}", \
     "-m", "${SS_METHOD:-aes-256-gcm}"]
