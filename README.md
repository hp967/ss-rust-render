# SS-Rust 部署说明

## Render 手动部署步骤

详见配套教程文档。

## 本地测试（Docker）

```bash
docker build -t ss-rust-test .
docker run -d \
  -p 8388:8388 \
  -e SS_PASSWORD="你的密码" \
  ss-rust-test
```

客户端连接信息：
- 服务器：你的 Render 服务地址（形如 `ss-rust-proxy.onrender.com`）
- 端口：8388
- 密码：Render Dashboard 配置的 `SS_PASSWORD`
- 加密：aes-256-gcm
