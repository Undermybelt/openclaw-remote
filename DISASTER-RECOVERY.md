# OpenClaw 灾难恢复手册

> 版本: 1.0 | 更新时间: 2026-02-09
> 目标: 2 小时内从零恢复全部服务

## 🚨 灾难场景

假设：
- 当前机器完全损坏/丢失
- 你拿到一台全新的 Mac
- 需要从零恢复所有 OpenClaw 服务

---

## 阶段一：基础环境（30 分钟）

### 1.1 安装 Homebrew
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 1.2 安装核心工具
```bash
brew install git node n
```

### 1.3 配置 Node.js
```bash
n lts
npm install -g npm@latest
```

### 1.4 配置 Git
```bash
git config --global user.name "Shagaku"
git config --global user.email "你的邮箱"
```

### 1.5 生成 SSH Key 并添加到 GitHub
```bash
ssh-keygen -t ed25519 -C "你的邮箱" -f ~/.ssh/id_ed25519 -N ""
cat ~/.ssh/id_ed25519.pub
```
→ 复制公钥到 https://github.com/settings/ssh/new

### 1.6 克隆 Workspace
```bash
mkdir -p ~/.openclaw/workspace
cd ~/.openclaw/workspace
git clone git@github.com:Undermybelt/openclaw-remote.git .
```

---

## 阶段二：恢复 OpenClaw（30 分钟）

### 2.1 安装 OpenClaw
```bash
npm install -g openclaw
```

### 2.2 安装全局 NPM 包
```bash
npm install -g bun clawdhub playwriter qmd ts-node
```

### 2.3 安装 Homebrew 工具
```bash
brew install go gogcli jq beads agent-browser
```

### 2.4 恢复 OpenClaw 配置

创建 `~/.openclaw/openclaw.json`（从备份获取）：

```json
{
  "env": {
    "TAVILY_API_KEY": "tvly-dev-xxx",
    "WECHAT_MP_APPID": "wxe8b992cb41f5106a",
    "WECHAT_MP_SECRET": "xxx",
    "PROMPTINTEL_API_KEY": "ak_xxx"
  },
  "auth": {
    "profiles": {
      "opencode:default": { "provider": "opencode", "mode": "api_key" },
      "openrouter:default": { "provider": "openrouter", "mode": "api_key" }
    }
  },
  "agents": {
    "defaults": {
      "model": { "primary": "openrouter/openrouter/pony-alpha" },
      "workspace": "/Users/thrill3r/.openclaw/workspace"
    }
  },
  "channels": {
    "discord": {
      "enabled": true,
      "token": "xxx",
      "groupPolicy": "open"
    }
  },
  "gateway": {
    "port": 18789,
    "mode": "local",
    "bind": "loopback",
    "auth": { "mode": "token", "token": "xxx" }
  }
}
```

### 2.5 配置 API Keys

**需要手动填入的敏感信息：**

| Key | 获取方式 |
|-----|----------|
| TAVILY_API_KEY | https://tavily.com |
| WECHAT_MP_* | 微信公众平台 |
| PROMPTINTEL_API_KEY | https://promptintel.com |
| Discord Token | Discord Developer Portal |
| Gateway Token | 随机生成 |

### 2.6 启动 Gateway
```bash
openclaw gateway start
```

### 2.7 验证基本功能
```bash
openclaw status
```

---

## 阶段三：恢复自动化（30 分钟）

### 3.1 恢复系统 Cron
```bash
# 健康检查（先配置 Healthchecks.io 新 URL）
echo "*/5 * * * * HEALTHCHECK_URL='https://hc-ping.com/xxx' ~/.openclaw/workspace/scripts/healthcheck.sh" | crontab -

# 每日备份
(crontab -l; echo "0 2 * * * ~/.openclaw/workspace/scripts/backup.sh") | crontab -

# 系统状态导出
(crontab -l; echo "0 3 * * * ~/.openclaw/workspace/scripts/export-state.sh && cd ~/.openclaw/workspace && git add -A && git commit -m 'Auto: Update system state' && git push") | crontab -
```

### 3.2 恢复 OpenClaw Cron 任务

Twitter 时间线摘要：
```bash
openclaw cron add \
  --name "Twitter 10min Summary" \
  --cron "*/30 * * * *" \
  --tz "Asia/Shanghai" \
  --session isolated \
  --message "使用 Playwriter 抓取 Twitter..." \
  --thinking low
```

### 3.3 恢复 hosts 安全屏蔽
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

### 3.4 配置 Healthchecks.io

1. 登录 https://healthchecks.io
2. 创建新检查点 `openclaw-heartbeat`
3. Period: 5 分钟, Grace: 10 分钟
4. 配置通知（Discord 推荐）
5. 更新 crontab 中的 URL

### 3.5 验证 Cron 任务
```bash
crontab -l
openclaw cron list
```

---

## 阶段四：验证（30 分钟）

### 4.1 手动触发关键任务
```bash
# 测试健康检查
HEALTHCHECK_URL='xxx' ~/.openclaw/workspace/scripts/healthcheck.sh

# 测试备份
~/.openclaw/workspace/scripts/backup.sh

# 测试 Twitter 摘要
openclaw cron run <twitter-job-id>
```

### 4.2 检查日志
```bash
# Gateway 日志
tail -f ~/.openclaw/logs/gateway.log

# 健康检查日志
cat ~/.openclaw/logs/healthcheck.log

# Twitter 任务日志
openclaw cron runs --id <job-id>
```

### 4.3 验证通知渠道
- Discord 消息能正常接收？
- Healthchecks.io 心跳正常？
- 备份推送到 GitHub 成功？

### 4.4 通知相关人员
- [ ] 系统已恢复
- [ ] 新的 Healthchecks.io URL
- [ ] 验证测试结果

---

## 📋 恢复检查清单

### 必须恢复的服务
- [ ] OpenClaw Gateway 运行
- [ ] Discord 连接正常
- [ ] Twitter 摘要任务运行
- [ ] 健康检查心跳正常
- [ ] Git 自动备份正常
- [ ] hosts 安全屏蔽配置

### 可选恢复的服务
- [ ] Playwriter 浏览器自动化（需要重新登录 Twitter）
- [ ] MoltThreats 威胁监控
- [ ] QMD 语义搜索

---

## 🔑 敏感信息清单

恢复时需要重新填入：

| 项目 | 位置 | 获取方式 |
|------|------|----------|
| TAVILY_API_KEY | openclaw.json | https://tavily.com |
| WECHAT_MP_APPID | openclaw.json | 微信公众平台 |
| WECHAT_MP_SECRET | openclaw.json | 微信公众平台 |
| PROMPTINTEL_API_KEY | openclaw.json | https://promptintel.com |
| Discord Token | openclaw.json | Discord Developer Portal |
| Gateway Token | openclaw.json | 随机生成 |
| Healthchecks URL | crontab | https://healthchecks.io |
| GitHub SSH Key | ~/.ssh/ | 本文档 1.5 |

---

## 🆘 紧急联系人

- GitHub 仓库：https://github.com/Undermybelt/openclaw-remote
- OpenClaw 文档：https://docs.openclaw.ai
- OpenClaw 社区：https://discord.com/invite/clawd

---

## 📝 演练记录

| 日期 | 耗时 | 问题 | 改进 |
|------|------|------|------|
| _ | _ | _ | _ |

**重要：每次系统变更后更新此手册！**
