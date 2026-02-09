# OpenClaw 灾难恢复手册

> 最后更新：2026-02-09 20:30
> 恢复时间目标 (RTO)：30 分钟
> 恢复点目标 (RPO)：1 小时（取决于最后备份）

---

## 🚨 紧急联系人

| 角色 | 联系方式 |
|------|----------|
| 主要负责人 | Shagaku (Discord) |
| Healthchecks 告警 | 配置了通知渠道 |

---

## 📋 灾难场景与恢复步骤

### 场景 1：OpenClaw Gateway 崩溃

**症状**：Healthchecks 连续失败，Discord/Telegram 无响应

**恢复步骤**：
```bash
# 1. SSH 到服务器（如果是远程）
ssh user@server

# 2. 检查 gateway 状态
openclaw gateway status

# 3. 查看日志
tail -100 ~/.openclaw/logs/gateway.log

# 4. 重启 gateway
openclaw gateway restart

# 5. 验证恢复
openclaw gateway status
curl http://localhost:3000/health  # 如果有健康检查端点
```

**预计恢复时间**：5 分钟

---

### 场景 2：服务器/机器完全丢失

**症状**：机器无法访问，硬件故障，云服务宕机

**恢复步骤**：

#### Step 1: 准备新机器
```bash
# 确保系统是 macOS/Linux
# 安装 Node.js (v18+)
# 安装 Homebrew (macOS)
```

#### Step 2: 克隆配置仓库
```bash
# 从 GitHub 克隆 workspace
git clone git@github.com:Undermybelt/openclaw-remote.git ~/.openclaw/workspace
```

#### Step 3: 安装 OpenClaw
```bash
npm install -g openclaw
```

#### Step 4: 恢复配置文件
```bash
# 从备份恢复 openclaw.json（包含 API keys）
# 选项 A: 从加密云存储下载
# 选项 B: 从 1Password/Bitwarden 获取
# 选项 C: 手动重新配置

cp ~/Downloads/openclaw.json ~/.openclaw/openclaw.json
```

#### Step 5: 安装依赖
```bash
# 安装系统依赖
brew install node

# 安装全局 npm 包
npm install -g pnpm bun

# 安装 Playwriter（如需要）
npm install -g @anthropic/playwriter
```

#### Step 6: 恢复 Cron 任务
```bash
# 检查 cron 任务
openclaw cron list

# 如果丢失，从 workspace/memory/checkpoints/ 恢复
# 手动重新创建任务
```

#### Step 7: 验证
```bash
# 启动 gateway
openclaw gateway start

# 检查健康状态
curl $HEALTHCHECK_URL

# 测试 Discord 消息
# 让用户在 Discord 发消息测试
```

**预计恢复时间**：30 分钟

---

### 场景 3：配置/密钥泄露

**症状**：发现 API key 被滥用，GitHub token 泄露

**立即行动**：
1. **撤销泄露的密钥**（最优先！）
   - Twitter/X: 开发者平台重新生成
   - Discord: Bot Token 重新生成
   - GitHub: Settings > Developer settings > Personal access tokens > 撤销
   - OpenAI/Anthropic: API Keys 页面撤销

2. **轮换所有相关密钥**
   ```bash
   # 编辑配置文件
   nano ~/.openclaw/openclaw.json
   
   # 更新所有可能受影响的密钥
   ```

3. **检查日志确认未被发现**
   ```bash
   # 检查是否有可疑活动
   grep -r "suspicious" ~/.openclaw/logs/
   ```

4. **提交清理后的代码**
   ```bash
   # 确保没有密钥在 git 历史中
   git filter-branch --force --index-filter \
     "git rm --cached --ignore-unmatch PATH_TO_FILE" \
     --prune-empty --tag-name-filter cat -- --all
   ```

---

### 场景 4：Git 仓库损坏/丢失

**症状**：`git status` 报错，无法 push/pull

**恢复步骤**：
```bash
# 1. 备份当前状态
cp -r ~/.openclaw/workspace ~/workspace-backup

# 2. 重新克隆
rm -rf ~/.openclaw/workspace
git clone git@github.com:Undermybelt/openclaw-remote.git ~/.openclaw/workspace

# 3. 如果本地有未推送的更改，从备份恢复
# 手动合并需要的文件
```

---

### 场景 5：Playwriter/Chrome 连接丢失

**症状**：Twitter 摘要 cron 失败，"Playwriter session not found"

**恢复步骤**：
```bash
# 1. 确保 Chrome 已打开
open -a "Google Chrome"

# 2. 检查 Playwriter 扩展状态
# 点击扩展图标，确保显示绿色/已连接

# 3. 重新创建 session
export PATH="$HOME/.npm-global/bin:$PATH"
playwriter session new

# 4. 记录新 session ID（通常是 1）
playwriter session list

# 5. 更新 cron 任务中的 session ID（如果变化）
```

---

## 📦 备份策略

### 自动备份
- **Git 仓库**：每次 `git push` 自动备份到 GitHub
- **心跳监控**：每 5 分钟检查 gateway 状态

### 手动备份（建议频率：每周）
```bash
# 运行备份脚本
~/.openclaw/workspace/scripts/backup.sh

# 或手动导出状态
~/.openclaw/workspace/scripts/export-state.sh
```

### 应备份的关键文件
| 文件 | 位置 | 包含内容 | 备份方式 |
|------|------|----------|----------|
| openclaw.json | ~/.openclaw/ | API keys, 配置 | 加密云存储/1Password |
| workspace/ | ~/.openclaw/workspace/ | 记忆、技能、脚本 | Git |
| .env (如有) | 各技能目录 | 环境变量 | 加密云存储 |

---

## ✅ 恢复验证清单

恢复后必须验证：

- [ ] Gateway 正常运行 (`openclaw gateway status`)
- [ ] Healthchecks 收到成功心跳
- [ ] Discord/Telegram 消息正常收发
- [ ] Cron 任务正常运行 (`openclaw cron list`)
- [ ] Playwriter 连接正常 (如使用)
- [ ] 关键 Skills 可用

---

## 🔧 预防措施

1. **定期备份**：每周运行备份脚本
2. **监控告警**：Healthchecks 配置邮件/Webhook 通知
3. **密钥管理**：使用 1Password/Bitwarden 存储，不在代码中硬编码
4. **文档更新**：重大变更后更新此手册
5. **定期演练**：每月检查一次恢复流程是否可行

---

## 📝 版本历史

| 日期 | 变更 |
|------|------|
| 2026-02-09 | 初始版本 |

---

**记住**：最关键的是先保护好密钥，其他都可以从 Git 恢复！
