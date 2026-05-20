# ================================
# SS-Rust Render — COPY 预编译 amd64 二进制
# 二进制来自 shadowsocks-rust v1.21.2 Release
# x86_64-unknown-linux-musl (静态链接，无需额外运行库)
# ================================

FROM scratch

# COPY 预编译的 amd64 二进制
COPY bin/ssserver /usr/local/bin/ssserver
COPY bin/ssserver /usr/local/bin/shadowsocks-server

# 设置环境变量默认值
ENV SS_SERVER_PORT=8388
ENV SS_METHOD=aes-256-gcm

EXPOSE 8388

# 这个CMD会被render.yaml中的cmd覆盖
# 保留为默认启动选项
CMD ["/usr/local/bin/ssserver", "-s", "0.0.0.0:8388", "-k", "default-password", "-m", "aes-256-gcm"]