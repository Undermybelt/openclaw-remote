# DISASTER-RECOVERY.md - 灾难恢复手册

> 目标：从零开始，2 小时内恢复全部 OpenClaw 服务
> 最后更新：2026-02-09

---

## 📋 前置准备

### 必需信息
- [ ] GitHub 账号和仓库访问权限
- [ ] Healthchecks.io 账号
- [ ] API Keys 备份（安全存储）
- [ ] Discord 账号

### 敏感信息清单
```
需要恢复的 API Keys：
1. TAVILY_API_KEY
2. WECHAT_MP_APPID / WECHAT_MP_SECRET
3. PROMPTINTEL_API_KEY (MoltThreats)
4. Discord Bot Token
5. OpenClaw Gateway Token
6. OpenRouter API Key
```

---

## 🚀 阶段一：基础环境（30 分钟）

### Step 1: 安装 Homebrew
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Step 2: 安装核心工具
```bash
# Git
brew install git

# Node.js
brew install node

# 验证安装
git --version
node --version
npm --version
```

### Step 3: 配置 Git
```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

### Step 4: 配置 SSH Key
```bash
# 生成 SSH Key
ssh-keygen -t ed25519 -C "your@email.com" -f ~/.ssh/id_ed25519 -N ""

# 添加到 ssh-agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# 显示公钥（添加到 GitHub）
cat ~/.ssh/id_ed25519.pub
```

**→ 去 GitHub Settings → SSH Keys → Add New**

### Step 5: 克隆 Workspace
```bash
mkdir -p ~/.openclaw
cd ~/.openclaw
git clone git@github.com:Undermybelt/openclaw-remote.git workspace
cd workspace
```

---

## ⚙️ 阶段二：恢复 OpenClaw（30 分钟）

### Step 6: 安装 OpenClaw
```bash
npm install -g openclaw
```

### Step 7: 安装全局 NPM 包
```bash
npm install -g \
  bun \
  clawdhub \
  playwriter \
  pnpm \
  ts-node
```

### Step 8: 安装 Homebrew 依赖
```bash
# 从备份恢复
brew install \
  git \
  gh \
  go \
  jq \
  curl \
  ffmpeg \
  beads \
  gogcli \
  imsg \
  camsnap \
  gifgrep \
  agent-browser
```

### Step 9: 恢复 OpenClaw 配置
```bash
# 创建配置文件
cd ~/.openclaw
touch openclaw.json
```

**手动填入（从安全备份获取）：**
```json
{
  "env": {
    "TAVILY_API_KEY": "tvly-dev-XXX",
    "WECHAT_MP_APPID": "wxe8b992cb41f5106a",
    "WECHAT_MP_SECRET": "XXX",
    "PROMPTINTEL_API_KEY": "ak_XXX"
  },
  "channels": {
    "discord": {
      "enabled": true,
      "token": "XXX"
    }
  },
  "gateway": {
    "port": 18789,
    "mode": "local",
    "bind": "loopback",
    "auth": {
      "mode": "token",
      "token": "XXX"
    }
  }
}
```

### Step 10: 安装 Skills
```bash
# 通过 ClawHub 安装
npx clawhub@latest install tavily-search
npx clawhub@latest install humanizer
npx clawhub@latest install proactive-agent
npx clawhub@latest install planning-with-files
npx clawhub@latest install MoltThreats

# Workspace skills 已在 Git 中
cd ~/.openclaw/workspace/skills
# 所有 skills 已通过 git clone 恢复
```

### Step 11: 启动 Gateway
```bash
# 启动并验证
openclaw gateway start
openclaw status
```

---

## 🔄 阶段三：恢复自动化（30 分钟）

### Step 12: 恢复 Cron 任务

**OpenClaw Cron:**
```bash
# Twitter 时间线摘要
openclaw cron add \
  --name "Twitter 10min Summary" \
  --cron "*/30 * * * *" \
  --tz "Asia/Shanghai" \
  --session isolated \
  --message "使用 Playwriter 抓取 Twitter..." \
  --thinking low
```

**系统 Cron:**
```bash
# 健康检查（先去 Healthchecks.io 创建检查点）
echo "*/5 * * * * HEALTHCHECK_URL='https://hc-ping.com/YOUR-NEW-URL' /Users/thrill3r/.openclaw/workspace/scripts/healthcheck.sh" | crontab -

# Git 自动备份
echo "0 2 * * * /Users/thrill3r/.openclaw/workspace/scripts/backup.sh" | crontab -

# 系统状态导出
echo "0 3 * * * /Users/thrill3r/.openclaw/workspace/scripts/export-state.sh && cd /Users/thrill3r/.openclaw/workspace && git add -A && git commit -m 'Auto: Update system state' && git push" | crontab -
```

### Step 13: 配置 Playwriter
```bash
# 安装 Chrome 扩展
# 手动：在 Chrome 中安装 Playwriter 扩展

# 创建 session
playwriter session create

# 验证
playwriter session list
```

### Step 14: 恢复健康检查
```bash
# 1. 登录 https://healthchecks.io
# 2. 创建新检查点：openclaw-heartbeat
# 3. Period: 5 min, Grace: 10 min
# 4. 获取 Ping URL
# 5. 更新 crontab 中的 HEALTHCHECK_URL
```

---

## ✅ 阶段四：验证（30 分钟）

### Step 15: 验证基础功能
```bash
# OpenClaw 状态
openclaw status

# Gateway 健康检查
curl http://localhost:18789/health

# Cron 任务列表
openclaw cron list
```

### Step 16: 验证 Cron 任务
```bash
# 手动触发 Twitter 摘要
openclaw cron run 0e591fef-e90a-49a8-912d-c0cdedc2d1e8

# 检查日志
tail -f ~/.openclaw/logs/cron.log
```

### Step 17: 验证心跳监控
```bash
# 手动执行健康检查
HEALTHCHECK_URL='YOUR-URL' ~/.openclaw/workspace/scripts/healthcheck.sh

# 检查日志
tail -f ~/.openclaw/logs/healthcheck.log

# 去 Healthchecks.io 确认收到 ping
```

### Step 18: 验证 Git 备份
```bash
cd ~/.openclaw/workspace
git status
git log --oneline -5

# 手动触发备份
~/.openclaw/workspace/scripts/backup.sh
```

### Step 19: 端到端测试
```bash
# 1. 发送测试消息到 Discord
openclaw message send "恢复完成！OpenClaw 已上线" --channel discord --target user:YOUR_USER_ID

# 2. 等待下一次 Twitter 摘要（30 分钟内）

# 3. 检查 Healthchecks.io 仪表板
```

---

## 🛡️ 安全加固

### Hosts 文件屏蔽
```bash
sudo -- sh -c 'echo "
# OpenClaw security: block malicious .md domains
127.0.0.1 heartbeat.md
127.0.0.1 agents.md
127.0.0.1 soul.md
127.0.0.1 user.md
127.0.0.1 tools.md
127.0.0.1 memory.md
127.0.0.1 identity.md
127.0.0.1 bootstrap.md" >> /etc/hosts'
```

### 验证屏蔽生效
```bash
cat /etc/hosts | grep "\.md"
```

---

## 📞 联系人 & 资源

### 紧急联系
- **GitHub 仓库**: https://github.com/Undermybelt/openclaw-remote
- **Healthchecks.io**: https://healthchecks.io
- **OpenClaw 文档**: https://docs.openclaw.ai
- **Discord 社区**: https://discord.com/invite/clawd

### 关键文件位置
```
~/.openclaw/
├── openclaw.json           # 主配置
├── workspace/              # Git 仓库
│   ├── MEMORY.md           # 长期记忆
│   ├── scripts/            # 脚本
│   └── skills/             # Workspace skills
├── skills/                 # 全局 skills
└── logs/                   # 日志
    ├── healthcheck.log
    └── backup.log
```

---

## 🔥 常见问题

### Q1: Gateway 启动失败
```bash
# 检查端口占用
lsof -i :18789

# 检查配置
openclaw config get

# 重新启动
openclaw gateway restart
```

### Q2: Cron 任务不执行
```bash
# 检查 cron 服务
pgrep -fl cron

# 检查 OpenClaw cron
openclaw cron list

# 手动触发测试
openclaw cron run <job-id>
```

### Q3: Discord 消息发送失败
```bash
# 验证 token
openclaw config get | grep discord

# 测试发送
openclaw message send "test" --channel discord --target user:YOUR_ID
```

### Q4: Playwriter Session 失效
```bash
# 重新创建 session
playwriter session create

# 确保 Chrome 打开 + 扩展绿色
```

---

## 📊 恢复检查清单

打印此清单，恢复时逐项勾选：

```
□ Homebrew 安装完成
□ Git 配置完成
□ SSH Key 添加到 GitHub
□ Workspace 克隆完成
□ OpenClaw 安装完成
□ 全局 NPM 包安装完成
□ Homebrew 依赖安装完成
□ openclaw.json 配置完成
□ API Keys 填入完成
□ Skills 安装完成
□ Gateway 启动成功
□ OpenClaw Cron 任务恢复
□ 系统 Cron 任务恢复
□ Playwriter Session 创建
□ Healthchecks.io 检查点创建
□ 基础功能验证通过
□ Cron 任务验证通过
□ 心跳监控验证通过
□ Git 备份验证通过
□ 端到端测试通过
□ Hosts 文件屏蔽完成
□ Discord 消息发送测试成功
```

---

## 📝 演练记录

| 日期 | 耗时 | 问题 | 解决方案 |
|------|------|------|----------|
| YYYY-MM-DD | XX min | - | - |

---

**重要提醒：**
1. 此手册每季度更新一次
2. 每次 OpenClaw 升级后验证兼容性
3. API Keys 变更时立即更新备份
4. 每年至少做一次完整演练

**手册版本**: 1.0
**创建日期**: 2026-02-09
**下次更新**: 2026-05-09
