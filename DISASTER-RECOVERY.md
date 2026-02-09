# OpenClaw 灾难恢复手册

> 最后更新：2026-02-09
> 优先级：P2
> 状态：✅ 已创建

---

## 🚨 紧急情况分类

| 级别 | 描述 | 响应时间 |
|------|------|----------|
| **P0** | Gateway 完全宕机，无法启动 | 立即 |
| **P1** | 数据丢失（workspace/skills 被删） | 1 小时内 |
| **P2** | 配置损坏，部分功能失效 | 4 小时内 |

---

## 📦 备份位置

| 内容 | 位置 | 频率 |
|------|------|------|
| **Workspace Git** | `git@github.com:Undermybelt/openclaw-remote.git` | 手动 push |
| **OpenClaw 配置** | `~/.openclaw/openclaw.json` | 无自动备份 |
| **系统 Crontab** | 本地，需手动导出 | - |
| **Skills 列表** | 见本文档附录 | - |

---

## 🔄 恢复流程

### 场景 1: Gateway 无法启动

```bash
# 1. 检查进程
ps aux | grep openclaw

# 2. 查看日志
tail -100 ~/.openclaw/logs/gateway.log

# 3. 重启 Gateway
openclaw gateway stop
openclaw gateway start

# 4. 如果还不行，重启 Node
# (如果有 PM2)
pm2 restart openclaw-gateway
```

### 场景 2: Workspace 丢失

```bash
# 1. 克隆仓库
git clone git@github.com:Undermybelt/openclaw-remote.git ~/.openclaw/workspace

# 2. 恢复子模块
cd ~/.openclaw/workspace
git submodule update --init --recursive

# 3. 恢复环境变量
# 手动设置 HEALTHCHECK_URL 等敏感变量
```

### 场景 3: OpenClaw 配置损坏

```bash
# 1. 查看当前配置
cat ~/.openclaw/openclaw.json

# 2. 重新配置 API Keys
openclaw config edit

# 需要重新配置的 Keys:
# - TAVILY_API_KEY
# - WECHAT_MP_APPID
# - WECHAT_MP_SECRET
# - PROMPTINTEL_API_KEY
# - Discord Bot Token
```

### 场景 4: Cron 任务丢失

```bash
# 1. 检查 OpenClaw cron
openclaw cron list

# 2. 如果为空，重新创建 Twitter 摘要任务
# 见附录 A：Cron 任务配置
```

### 场景 5: Skills 丢失

```bash
# 1. 检查已安装 Skills
ls ~/.openclaw/skills/
ls ~/.openclaw/workspace/skills/

# 2. 重新安装（见附录 B：Skills 列表）
```

---

## 🔐 敏感信息恢复

**⚠️ 以下信息不在 Git 中，需要手动恢复：**

| 变量 | 存储位置 | 获取方式 |
|------|----------|----------|
| `HEALTHCHECK_URL` | 环境变量 | Healthchecks.io Dashboard |
| `TAVILY_API_KEY` | openclaw.json | https://tavily.com/ |
| `WECHAT_MP_APPID` | openclaw.json | 微信公众平台 |
| `WECHAT_MP_SECRET` | openclaw.json | 微信公众平台 |
| `PROMPTINTEL_API_KEY` | openclaw.json | MoltThreats |
| Discord Bot Token | openclaw.json | Discord Developer Portal |

---

## 📋 附录 A: Cron 任务配置

### Twitter 时间线摘要（每 30 分钟）

```bash
openclaw cron add --name "Twitter 30min Summary" \
  --schedule "*/30 * * * *" \
  --session-target isolated \
  --payload '使用 Playwriter 抓取 Twitter 首页时间线，筛选后发送到 Discord DM。筛选标准：MCP/Skills、前沿AI、免费资源、赚钱、有趣洞见。'
```

---

## 📋 附录 B: Skills 列表

### 全局 Skills (`~/.openclaw/skills/`)

| Skill | 安装命令 |
|-------|----------|
| tavily-search | `clawhub install tavily-search` |
| humanizer | `clawhub install humanizer` |
| proactive-agent | `clawhub install proactive-agent` |
| planning-with-files | `clawhub install planning-with-files` |
| md2wechat | `curl -fsSL ... \| bash` (见 GitHub) |

### Workspace Skills (`~/.openclaw/workspace/skills/`)

| Skill | 来源 |
|-------|------|
| playwriter-skill | Git submodule |
| superpowers | Git submodule |
| MoltThreats | Git submodule |
| anthropic-docx/pdf/pptx/xlsx | Git submodule |
| remotion-skills | Git submodule |
| yt-dlp-downloader-skill | Git submodule |

---

## 📋 附录 C: 系统依赖

```bash
# Node.js 版本
node -v  # 应为 v22+

# 全局 NPM 包
npm list -g --depth=0

# Homebrew 包（macOS）
brew list

# 关键 CLI
which openclaw
which playwriter
which agent-browser
```

---

## 📞 联系方式

- **OpenClaw 官方文档**: https://docs.openclaw.ai
- **OpenClaw Discord**: https://discord.com/invite/clawd
- **GitHub Issues**: https://github.com/openclaw/openclaw/issues

---

## ✅ 恢复后检查清单

- [ ] Gateway 正常运行 (`openclaw gateway status`)
- [ ] 心跳正常 (Healthchecks.io 显示绿色)
- [ ] Cron 任务运行中 (`openclaw cron list`)
- [ ] Discord bot 在线
- [ ] Playwriter 可用 (`playwriter session list`)
- [ ] 关键 Skills 可用

---

*此文档应定期更新，特别是在添加新 Skills 或修改配置后。*
