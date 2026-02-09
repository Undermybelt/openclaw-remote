# MEMORY.md - 长期记忆

> 最后更新：2026-02-09 17:40

## 👤 用户信息

- **名称**：Shagaku
- **平台**：Discord
- **偏好**：中文 + 英文技术术语混合
- **时区**：Asia/Shanghai

---

## 🔧 系统配置

### 灾备方案（参考 xiyu 文章）
| 优先级 | 任务 | 状态 |
|--------|------|------|
| **P0** | Healthchecks.io 心跳监控 | ✅ 完成 |
| P1 | 数据备份（Git + 加密云存储） | ⏳ 待做 |
| P2 | 灾难恢复手册 | ⏳ 待做 |

**心跳配置**：
- URL: `配置在环境变量 HEALTHCHECK_URL`
- 脚本: `~/.openclaw/workspace/scripts/healthcheck.sh`
- Cron: 每 5 分钟检查 gateway 进程
- 日志: `~/.openclaw/logs/healthcheck.log`

> ⚠️ **安全提示**：心跳 URL 已移至环境变量，不要提交到仓库

### 已安装的 Skills
| Skill | 用途 | 位置 |
|-------|------|------|
| tavily-search | 网络搜索 | ~/.openclaw/skills/ |
| humanizer | 洗稿工具 | ~/.openclaw/skills/ |
| playwriter | 浏览器自动化 | workspace/skills/ |
| superpowers (14个) | 开发技能 | workspace/skills/ |
| anthropic-pdf/docx/pptx/xlsx | 文档处理 | workspace/skills/ |
| proactive-agent | 主动代理 | ~/.openclaw/skills/ |
| planning-with-files | 文件规划 | ~/.openclaw/skills/ |
| MoltThreats | 动态安全防护 | workspace/skills/ |

### API Keys（已配置）
- ✅ TAVILY_API_KEY
- ✅ WECHAT_MP_APPID / SECRET
- ✅ PROMPTINTEL_API_KEY (MoltThreats)

### Cron 任务
| 任务 | 频率 | 状态 |
|------|------|------|
| Twitter 时间线摘要 | 每10分钟 | ✅ 运行中 |

---

## 📋 活跃项目

### 1. Twitter 时间线摘要机器人
- **创建时间**：2026-02-08
- **工具**：Playwriter
- **输出**：Discord DM
- **筛选标准**：
  - MCP/Skills 相关
  - 前沿 AI 消息
  - 免费资源
  - 赚钱机会
  - 有意思的洞见
- **格式**：见 cron 任务配置
- **依赖**：Chrome + Playwriter 扩展（绿色）

---

## 🎓 学到的教训

### 2026-02-09
1. **⚠️ ClawHub 恶意 Skills 投毒事件**：慢雾 MistEye 发现 ClawHub 上超过 1/10 的 Skills 含有后门，会引导 OpenClaw 下载恶意软件。影响 Linux/Windows/macOS。需谨慎安装未知 Skills！
2. **🛡️ hosts 文件安全加固**：OpenClaw 的 7 个核心 .md 文件名（heartbeat.md, agents.md, soul.md, user.md, tools.md, memory.md, identity.md, bootstrap.md）已被恶意注册为域名。已在 /etc/hosts 中全部屏蔽到 127.0.0.1。

### 2026-02-08
1. **Discord DM 需要用 message tool**：isolated session 的 delivery 机制无法直接 DM 用户
2. **Playwriter 需要保持 Chrome 打开**：它控制用户现有的浏览器，不会自动启动
3. **"不感兴趣"操作太慢**：会导致任务超时（10分钟+）

---

## 📚 参考资料

### CodeGuard 安全规则集 (CoSAI/OASIS)
- **位置**: `~/.openclaw/workspace/reference/codeguard/`
- **来源**: https://github.com/cosai-oasis/project-codeguard
- **内容**: 110 个安全规则（24 Core + 86 OWASP）
- **用途**: OpenClaw Skills 安全编写参考
- **重点**: MCP Security, Input Validation, Supply Chain Security
- **索引**: `reference/codeguard/INDEX.md`

---

## 📌 待办事项

- [ ] QMD 语义搜索测试
- [ ] 验证所有 skills 正常工作
- [ ] 定期清理 memory/ 目录

---

## 🔄 上下文检查点

**检查点文件**: `memory/checkpoints/2026-02-08-latest.md`

**关键恢复信息**:
- Playwriter Session: 1
- Discord User: 当前用户 DM
- Cron Job: Twitter 时间线摘要任务

压缩后恢复时，执行：
1. `read memory/checkpoints/2026-02-08-latest.md`
2. `playwriter session list` 验证连接
3. `cron action=list` 验证任务
