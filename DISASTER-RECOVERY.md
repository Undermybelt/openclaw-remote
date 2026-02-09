# OpenClaw 灾难恢复手册

> 目标：2小时内从零恢复全部服务
> 场景：当前机器完全损坏，拿到全新 Mac Mini
> 最后更新：2026-02-09

---

## 阶段一：基础环境（30分钟）

### 1.1 安装 Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### 1.2 安装核心工具

```bash
brew install git node python gh jq curl go
```

### 1.3 配置 Git

```bash
git config --global user.name "Undermybelt"
git config --global user.email "your-email@example.com"
```

### 1.4 生成 SSH Key 并添加到 GitHub

```bash
ssh-keygen -t ed25519 -C "your-email@example.com" -f ~/.ssh/id_ed25519 -N ""
cat ~/.ssh/id_ed25519.pub
```

**复制公钥，添加到 GitHub：** https://github.com/settings/ssh/new

```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPMxcNhIY08/roihpTFxtB6Gsw2voiUJbQnzQVympLaH
```

### 1.5 测试 SSH 连接

```bash
ssh -T git@github.com
```

---

## 阶段二：恢复 OpenClaw（30分钟）

### 2.1 安装 OpenClaw 和依赖

```bash
npm install -g openclaw playwriter opencode-ai qmd
```

### 2.2 克隆 Workspace

```bash
git clone git@github.com:Undermybelt/openclaw-remote.git ~/.openclaw/workspace
```

### 2.3 配置 API Keys

创建 `~/.openclaw/openclaw.json`：

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
      "opencode:default": {"provider": "opencode", "mode": "api_key"},
      "openrouter:default": {"provider": "openrouter", "mode": "api_key"}
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
    "auth": {"mode": "token", "token": "xxx"}
  }
}
```

**⚠️ 需要从安全备份恢复的 Keys：**
- TAVILY_API_KEY
- WECHAT_MP_SECRET
- PROMPTINTEL_API_KEY
- Discord token
- Gateway auth token

### 2.4 启动 Gateway

```bash
openclaw gateway start
```

### 2.5 验证基本功能

```bash
openclaw status
```

---

## 阶段三：恢复自动化（30分钟）

### 3.1 配置系统 Cron（Healthcheck）

```bash
echo "*/5 * * * * HEALTHCHECK_URL='https://hc-ping.com/dfa9a6c4-958c-4847-bcf8-7d2602452623' /Users/thrill3r/.openclaw/workspace/scripts/healthcheck.sh" | crontab -
```

### 3.2 恢复 OpenClaw Cron 任务

Twitter 摘要任务（需要 Playwriter Session）：

```bash
openclaw cron add \
  --name "Twitter 30min Summary" \
  --cron "*/30 * * * *" \
  --tz "Asia/Shanghai" \
  --session isolated \
  --message "使用 Playwriter 抓取 Twitter 首页时间线..." \
  --thinking low
```

### 3.3 配置每日备份

```bash
(crontab -l; echo "0 2 * * * /Users/thrill3r/.openclaw/workspace/scripts/backup.sh") | crontab -
(crontab -l; echo "0 3 * * * /Users/thrill3r/.openclaw/workspace/scripts/export-state.sh && cd /Users/thrill3r/.openclaw/workspace && git add -A && git commit -m 'Auto: Update system state' && git push") | crontab -
```

### 3.4 安装 Playwriter 扩展

1. 打开 Chrome
2. 安装 Playwriter 扩展
3. 创建 Session 1（Twitter）
4. 保持 Chrome 打开

---

## 阶段四：验证（30分钟）

### 4.1 检查 Healthcheck

```bash
HEALTHCHECK_URL='https://hc-ping.com/dfa9a6c4-958c-4847-bcf8-7d2602452623' /Users/thrill3r/.openclaw/workspace/scripts/healthcheck.sh
cat /Users/thrill3r/.openclaw/logs/healthcheck.log
```

登录 https://healthchecks.io 确认收到心跳。

### 4.2 检查 Cron 任务

```bash
openclaw cron list
crontab -l
```

### 4.3 手动触发 Twitter 摘要

```bash
openclaw cron run <job-id>
```

检查 Discord 是否收到消息。

### 4.4 检查日志

```bash
tail -50 /Users/thrill3r/.openclaw/logs/healthcheck.log
```

### 4.5 验证 Git 同步

```bash
cd ~/.openclaw/workspace
git status
git log --oneline -5
```

---

## 敏感信息清单

| 项目 | 位置 | 备注 |
|------|------|------|
| TAVILY_API_KEY | openclaw.json | 从 https://tavily.com 获取 |
| WECHAT_MP_SECRET | openclaw.json | 微信公众号后台 |
| PROMPTINTEL_API_KEY | openclaw.json | MoltThreats 用 |
| Discord token | openclaw.json | Discord Developer Portal |
| Gateway auth token | openclaw.json | 随机生成 |
| Healthcheck URL | crontab | https://healthchecks.io |

**⚠️ 这些信息必须从安全备份（加密云存储/密码管理器）恢复！**

---

## 安装的 Skills 清单

### 全局 Skills (`~/.openclaw/skills/`)
- md2wechat
- proactive-agent

### Workspace Skills (`~/.openclaw/workspace/skills/`)
- MoltThreats
- annas-to-notebooklm
- anthropic-docx/pdf/pptx/xlsx
- superpowers (14个)
- tavily-search
- playwriter-skill
- humanizer
- 其他 20+ skills

**恢复方式**：已在 Git 仓库中，clone 后自动恢复。

---

## NPM 全局包

```bash
npm install -g openclaw@2026.2.6-3 playwriter@0.0.56 opencode-ai@1.1.53 qmd@1.0.0
```

---

## Homebrew 包

```bash
brew install git node python@3.13 gh jq curl go gogcli
```

---

## 故障排查

### Gateway 无法启动
```bash
openclaw gateway stop
rm -rf ~/.openclaw/gateway.db
openclaw gateway start
```

### Cron 任务不执行
```bash
# 检查 cron 服务
launchctl list | grep cron

# 检查脚本权限
chmod +x ~/.openclaw/workspace/scripts/*.sh
```

### Playwriter 失败
- 确认 Chrome 已打开
- 确认 Playwriter 扩展已安装且为绿色
- 重新创建 Session：`playwriter session create`

---

## 联系方式

- **GitHub**: https://github.com/Undermybelt
- **Discord**: shagaku._ (user:614743479154769960)
- **Healthcheck**: https://healthchecks.io

---

## 演练记录

| 日期 | 耗时 | 问题 | 备注 |
|------|------|------|------|
| | | | |

**每次系统变更后更新此手册！**
