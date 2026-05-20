# ================================
# SS-Rust Render — COPY 预编译 amd64 二进制
# 二进制来自 shadowsocks-rust v1.21.2 Release
# x86_64-unknown-linux-musl (静态链接，无需额外运行库)
# ================================

FROM busybox:uclibc

# COPY 预编译的 amd64 二进制
COPY bin/ssserver /usr/local/bin/ssserver
COPY bin/ssserver /usr/local/bin/shadowsocks-server

ENV PATH="/usr/local/bin:${PATH}"
ENV SS_SERVER_PORT=8388 \
    SS_METHOD=aes-256-gcm

EXPOSE 8388

# 使用 shell 格式确保 ${} 环境变量被展开
CMD /usr/local/bin/ssserver \
    -s "0.0.0.0:${SS_SERVER_PORT}" \
    -k "${SS_PASSWORD}" \
    -m "${SS_METHOD}"