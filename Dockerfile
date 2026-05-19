# ================================
# SS-Rust Render — COPY 预编译 amd64 二进制
# 二进制来自 shadowsocks-rust v1.21.2 Release
# x86_64-unknown-linux-musl (静态链接，无需额外运行库)
# ================================

FROM alpine:3.21

RUN apk add --no-cache ca-certificates bash && \
    update-ca-certificates

# COPY 预编译的 amd64 二进制（musl 静态链接，兼容 Alpine）
COPY bin/ssserver /usr/local/bin/ssserver
COPY bin/ssserver /usr/local/bin/shadowsocks-server
RUN chmod +x /usr/local/bin/ssserver /usr/local/bin/shadowsocks-server && \
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
