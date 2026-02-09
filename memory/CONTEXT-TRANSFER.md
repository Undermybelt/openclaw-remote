# Context Transfer Protocol

> 参考：Zac (@PerceptualPeak) 解决 CLAWD BOT 的 context transfer 问题

## 问题

当 OpenClaw 会话被压缩（compaction）时：
1. 之前的详细对话历史被摘要替代
2. 重要的上下文可能丢失
3. 压缩前后的记忆不连续

## 解决方案

### 1. 会话快照（Session Snapshot）

在每次重要操作后，保存快照到 `memory/snapshots/`：

```json
{
  "timestamp": "2026-02-08T17:57:00Z",
  "sessionType": "main",
  "activeTasks": ["Twitter 时间线摘要 cron"],
  "importantDecisions": ["使用 Playwriter 抓取 Twitter", "筛选标准已设定"],
  "pendingActions": ["监控 cron 任务运行"],
  "contextHash": "abc123"
}
```

### 2. 记忆检查点（Memory Checkpoint）

在压缩发生时，创建检查点：

```
memory/checkpoints/
├── 2026-02-08-1757-checkpoint.md
├── 2026-02-08-1700-checkpoint.md
└── ...
```

检查点格式：
```markdown
# Checkpoint: 2026-02-08 17:57

## 当前状态
- 正在运行：Twitter 时间线摘要（每10分钟）
- Playwriter session: 1（已连接）

## 重要决策
1. 选择 Playwriter 而非内置浏览器（需要登录状态）
2. 筛选标准：MCP/Skills、前沿AI、免费资源、赚钱机会

## 待办事项
- [ ] 监控 cron 任务稳定性
- [ ] 验证 Discord 推送正常

## 上下文线索
- 用户偏好：中文 + 英文技术术语
- Chrome + Playwriter 需要保持运行
```

### 3. 压缩后恢复（Post-Compaction Recovery）

当检测到会话被压缩时：

1. 读取最近的 checkpoint
2. 恢复关键上下文：
   - 活跃任务
   - 重要决策
   - 待办事项
3. 继续执行

### 4. 实现方式

在 AGENTS.md 中添加：

```markdown
## 会话恢复协议

每次会话开始时：
1. 检查 `memory/checkpoints/` 最新文件
2. 如果存在未完成任务，确认是否继续
3. 恢复重要上下文

每次重要操作后：
1. 更新当前 checkpoint
2. 保存关键决策到 MEMORY.md
```

## 快速实施

### 立即创建的文件

1. **MEMORY.md** - 长期记忆
2. **memory/checkpoints/** - 检查点目录
3. **memory/snapshots/** - 快照目录

### 自动触发

在以下时机自动保存检查点：
- 创建 cron 任务后
- 完成重要配置后
- 会话结束前
- 每小时固定时间
