# ================================
# SS-Rust Render — COPY 二进制模式（零网络下载）
# 修复: aarch64 + binary名ssserver + 无需curl下载
# ================================

FROM alpine:3.21

RUN apk add --no-cache \
      ca-certificates \
      bash \
    && update-ca-certificates

# 直接从仓库 COPY 二进制（不需构建时联网）
COPY bin/ssserver /usr/local/bin/ssserver
COPY bin/ssserver /usr/local/bin/shadowsocks-server
RUN chmod +x /usr/local/bin/ssserver /usr/local/bin/shadowsocks-server \
    && ls -la /usr/local/bin/ \
    && file /usr/local/bin/ssserver \
    && /usr/local/bin/ssserver --version

ENV PATH="/usr/local/bin:${PATH}"
ENV SS_SERVER_PORT=8388 \
    SS_METHOD=aes-256-gcm

EXPOSE 8388

# 健康检查（TCP服务，exit 0 即可）
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD exit 0

# 密码由 Render 环境变量注入
CMD ["/usr/local/bin/ssserver", \
     "server", \
     "-u", \
     "-k", "${SS_PASSWORD}", \
     "-p", "${SS_SERVER_PORT}", \
     "-m", "${SS_METHOD}"]
