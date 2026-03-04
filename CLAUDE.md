# Cat Café 项目指南

## 项目愿景

**Cat Café** 是一个让三只 AI 猫猫（agent）真正协作的系统。核心问题：铲屎官不再需要在三个聊天窗口之间复制粘贴上下文。

### 三猫分工
- **布偶猫（Codex）**：价值澄清、深度思考、架构设计
- **缅因猫（Codex）**：落地验证、代码审查、细节把控
- **暹罗猫（minimax）**：破框反直觉、创意发散、视觉设计

### 核心理念
1. **猫是 Agent，不是 API** — 主动感知、自主决策、主动表达
2. **共享感知 = 真正协作** — 共享工作空间、共享记忆、共享上下文
3. **隐私与自主权** — CLI 输出是内心独白，post_message 是主动开口

---

## 功能演示目标（@docs/lessons/DEMO.md）

### 基础交互
- **00 召唤猫猫**：用 `@布偶猫` `@缅因猫` `@暹罗猫` 召唤不同的猫
- **01 猫猫状态栏**：实时显示每只猫的工作状态（思考中/工具调用/回复中/空闲）
- **02 猫猫配置**：每只猫独立的模型、上下文预算、人格设定、工具权限

### 多猫协作
- **03 A2A 调用**：猫猫互相 @ 对方，实现 Agent-to-Agent 协作
- **04 A2A 输出隔离**：被调用猫的"内心独白"不泄漏到聊天室
- **05 Session Chain**：上下文快满时自动交接班到新 session

### 富媒体交互
- **06 语音输入/输出**：支持语音交互，每只猫有独特的声音
- **07 富文本（Rich Blocks）**：卡片、代码 Diff、清单、图片轮播
- **08 Thread & Session**：多 Thread 管理 + 独立的 Session 状态

### 研发工作流
- **09 CLI Meta 信息**：查看猫猫底层 CLI 调用的详细信息
- **10 导出**：支持 Markdown/图片导出，多 Agent 标注
- **11 悄悄话**：Whisper 私信，支持桌游场景（猫猫杀、硅谷做题猫）
- **12-15 进阶**：猫猫日报、猫猫手机、研发自闭环、猫猫 Skills

---

---

## 架构关键点

### CLI 子进程模式
```
用户消息 → 后端路由 → 生成 CLI 命令 → spawn 子进程
                                    ↓
                            stdout: 最终回复 (NDJSON)
                            stderr: thinking/工具调用/进度
                                    ↓
                            两个流都要监听（活跃信号）
```

**CRITICAL：同时监听 stdout 和 stderr，否则会误判超时！**

### A2A 协议（Agent-to-Agent）
```
Path A (Worklist):
  猫 A 执行完 → 检测回复文本里的 @mention
             → 追加到 worklist
             → 继续循环执行猫 B

Path B (Callback - 待统一):
  猫 A 执行中 → 调用 MCP post_message(@猫B)
             → callback 检测到 @mention
             → 触发新 invocation（目前有问题）
```

**F27 修复方向**：callback 不再自己执行，改为追加到父 worklist。



**认证**：invocationId + callbackToken（环境变量传递，有 TTL）

### 短期记忆存储
- **Redis**：多猫共享状态、消息队列、session 数据
- **并发控制**：每只猫有独立的 session，共享状态需要隔离
- **数据隔离**：开发 Redis (6398) vs 生产 Redis (6399)

---

## 开发命令

### 运行时（cat-cafe-runtime/）
```bash
# 开发模式（热重载）
npm run dev

# 类型检查
npm run typecheck

# 生产构建
npm run build
npm start
```

### 测试
```bash
# PowerShell 测试脚本
./test-chat.ps1          # 基础聊天测试
./test-api.ps1           # API 测试
./test-simple.sh         # 简单测试
```

---

## 环境配置

复制 `.env.example` 到 `.env`：
```bash
CLI_OPENCODE_PATH=/path/to/opencode
CLI_TIMEOUT_MS=300000
DATA_DIR=./data
TRANSCRIPTS_DIR=./data/transcripts
REDIS_URL=redis://localhost:6399
```

**Worktree 开发必须使用隔离 Redis**：
```bash
echo "REDIS_URL=redis://localhost:6398" > .env.local
```

---

## 代码组织

```
cat-cafe-runtime/src/
├── config/env.ts              # 环境配置
├── runtime/spawnCli.ts        # CLI 子进程（CRITICAL：双流监听）
├── agents/
│   ├── types.ts               # 核心接口
│   ├── registry.ts            # 提供者路由
│   └── providers/             # 模型实现
├── session/sessionManager.ts  # Session 管理（线程隔离）
├── transcript/transcriptWriter.ts  # JSONL 事件日志
├── routes/
│   ├── health.ts              # 健康检查
│   ├── chat.ts                # 主聊天 API
│   └── callbacks.ts           # MCP 回调路由
├── schemas/chat.ts            # 请求验证
├── app.ts                      # Express 应用
└── server.ts                   # 入口
```

---

## 关键教训

### 1. stderr 也是活跃信号
CLI 在 thinking/工具调用时输出到 stderr，不是 stdout。只监听 stdout 会导致误判超时。

### 2. 两条路径 = 定时炸弹
A2A 有两条路径（Worklist + Callback），导致双重开火、无限递归、不可取消。F27 要统一为单一路径。

### 3. 数据隔离是铁律
开发环境必须使用隔离的 Redis/数据库。Worktree 开发时绝对不能连接生产数据库。

### 4. AI 会幻觉
AI 在信息不足时会编造看似合理的答案。强制"不确定就提问"。

### 5. 元规则要可执行
"要专业"没用，要写成可检查的规则（P1/P2/P3 分级、五件套交接、禁止表演性同意）。

---

---

## 铲屎官铁律

1. **不止血，一步到位** — 修复时要从根源解决，不要临时补丁
2. **两条路径 = 灾难** — 同一个操作只保留一条路径
3. **深度限制不可选** — 任何递归/链式执行都必须有上限
4. **所有后台执行都要可观测 + 可取消** — 不要 fire-and-forget
5. **开发环境必须隔离** — 绝对不能污染生产数据
6. **验证答案的正确性** — 不只是"有没有回答"
7. **行动说明一切** — 禁止表演性同意，直接修复

---

## 相关文档

- 📖 **愿景**：`@docs/VISION.md`
- 📖 **演示**：`@docs/lessons/DEMO.md`
- 📖 **第二课**：`@docs/lessons/02-cli-engineering.md`
- 📖 **第三课**：`@docs/lessons/03-meta-rules.md`
- 📖 **第四课**：`@docs/lessons/04-a2a-routing.md`
- 📖 **第五课**：`@docs/lessons/05-mcp-callback.md`

---

*最后更新：2026-03-04 | 由布偶猫、缅因猫、暹罗猫共同维护 🐾*
