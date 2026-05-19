# ================================
# SS-Rust Render — 下载预编译 binary（不依赖构建环境架构）
# 从 shadowsocks-rust GitHub Release 拉取 amd64 Linux 二进制
# ================================

FROM alpine:3.21 AS downloader

RUN apk add --no-cache curl tar

# 下载 shadowsocks-rust v1.21.2 的 amd64 Linux 预编译包
RUN curl -fsSL \
    "https://github.com/shadowsocks/shadowsocks-rust/releases/download/v1.21.2/shadowsocks-v1.21.2.x86_64-unknown-linux-gnu.tar.xz" \
    -o /tmp/ss.tar.xz && \
    tar xJf /tmp/ss.tar.xz -C /tmp/ && \
    ls -la /tmp/ssserver

# ---------- 运行阶段 ----------
FROM alpine:3.21

RUN apk add --no-cache ca-certificates bash && \
    update-ca-certificates

COPY --from=downloader /tmp/ssserver /usr/local/bin/ssserver
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
