# Render Secret 配置完整指南

适用场景：任何包含密码、Token、密钥等敏感信息的 Render 服务

---

## 🔑 什么是 Secret

Secret 是 Render 提供的**加密存储机制**，用来存放密码、API Key等敏感信息。

**和普通环境变量的区别**：

| | 普通环境变量（envVars） | Secret |
|---|---|---|
| **存储** | 明文存在 render.yaml 里 | 加密存在 Render 服务器 |
| **可见性** | 任何人能读到 git 就泄露 | 只有服务运行时可访问 |
| **修改** | 改配置文件重新 git push | Render Dashboard 一键修改 |
| **安全性** | ❌ 安全性差，不推荐 | ✅ 安全性最高 |

---

## 🚨 当前 render.yaml 的问题

```yaml
envVars:
  - key: SS_PASSWORD
    value: "YOUR_SECRET_PASSWORD_HERE"   # ← 占位符，不是真密码
```

- `SS_PASSWORD` 写死在 yaml 里，任何人拿到仓库都能看到密码
- 一旦真实密码进入 git 历史记录，删除注释后再改密码才有意义

**正确做法**：render.yaml 中只列 Secret 变量名，**不写 value**，到 Render Dashboard 里单独设。

---

## 📝 修改步骤（共三步）

### 第一步：更新 render.yaml（移除 value）

**旧版写法（有 value）**：

```yaml
envVars:
  - key: SS_PASSWORD
    value: "你的密码"          # ← ❌ 密码暴露在 git 里
```

**新版写法（无 value）**：

```yaml
envVars:
  - key: SS_PASSWORD
    # value 由 Dashboard 的 Secret 覆盖，这里留空
```

> 注意：`value` 字段可以直接删掉，或者填 `null`

### 第二步：Render Dashboard 设置 Secret

1. 打开 https://dashboard.render.com → 登录
2. 左侧菜单 → 找到 `ss-rust-proxy`（你的服务）
3. 顶部标签页 → **`Environment`**（不是 Settings）
4. 左侧 **Environment Variables** 区块 → 找到 `SS_PASSWORD`
5. 点击 `SS_PASSWORD` 行 → 右侧出现 **`⚙️ 编辑`** 按钮
6. 点击编辑 → **`Mode`** 下拉选 **`Secret`**
7. 输入你的真实密码 → **Save**

### 第三步：重启服务

Secret 修改后 Render 自动重启，无需额外操作。

---

## 🖼️ 界面示意（文字描述）

```
Render Dashboard / ss-rust-proxy / Environment
┌────────────────────────────────────────────────┐
│ Environment Variables                           │
│ ┌──────────────────────────────────────────────┐│
│ │ KEY           │ VALUE          │ SOURCE       ││
│ │ SS_SERVER_PORT│ 8388           │ render.yaml  ││
│ │ SS_METHOD     │ aes-256-gcm    │ render.yaml  ││
│ │ SS_PASSWORD   │ 🔒 Secret      │ Secret type  ││
│ └──────────────────────────────────────────────┘┘
└────────────────────────────────────────────────┘
```

- `🔒 Secret` 图标表示该项已设为 Secret，Dashboard 中看不到明文，只显示 `***...` 或 `🔒`

---

## 🔄 批量处理多环境

如果需要多个 Secret（例如密码 + 加密密钥），逐个添加即可：

```yaml
envVars:
  - key: SS_PASSWORD    # Secret 类型，在 Dashboard 设置
  - key: SS_MY_SECRET   # Secret 类型，在 Dashboard 设置
```

**注意**：
- render.yaml 里只能声明 key 和注释，**不能带 value**
- Secret 的值完全由 Render 服务器端管理，服务运行时可正常读取

---

## ⚠️ 常见问题

### Q：减少服务时内存不足怎么办？
**A**：看到 log.txt 里 `WEB_CONCURRENCY=1`，当前 512MB 内存仅够运行单个 Shadowsocks 实例。Render 免费版还能凑合用，遇到流量峰值可能会有延迟。

### Q：密码要摘要地改怎么办？
**A**：直接去 Environment 里重新 Save，Render 会立即热重载并不中断连接。

---

## ✅ 配置完成后发版

```bash
find /home/hp/ss-rust-render 2>&1 | head -10
```
确认 render.yaml 无敏感内容泄露后，`git push -u origin main`
