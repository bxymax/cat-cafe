# OpenCode CLI 配置指南

## 问题解决

### 1. 服务器无响应问题
**原因**: Express 5.2.1 存在兼容性问题
**解决**: 已降级到 Express 4.18.x（稳定版本）

现在 `curl localhost:3000/health` 应该正常返回：
```json
{"status":"ok","timestamp":"2026-03-01T15:50:59.224Z","uptime":1.1895319}
```

## OpenCode CLI 配置

### 方式一：全局安装 opencode CLI

如果你使用的是 opencode CLI 工具，需要先安装：

```bash
# 安装 opencode CLI（假设通过 npm）
npm install -g opencode

# 或者如果是其他安装方式，请按照 opencode 官方文档安装
```

### 方式二：配置本地路径

如果 opencode CLI 安装在特定位置，在 `.env` 文件中配置：

```bash
# .env 文件
CLI_OPENCODE_PATH=/path/to/opencode  # Linux/Mac
# 或
CLI_OPENCODE_PATH=C:\path\to\opencode.exe  # Windows
```

### 方式三：使用其他 CLI 工具

如果你使用的不是 opencode，而是其他 CLI 工具（如 `gpt-cli`, `minimax-cli` 等），需要修改 provider 代码：

#### 修改 GPT Provider

编辑 `src/agents/providers/gpt52Provider.ts`:

```typescript
// 原代码
const args = [
  'chat',
  '--model', 'gpt-5.2',
  '--message', request.message,
  '--thread-id', request.threadId,
];

const result = await spawnCli({
  command: config.cli.opencodePath,  // 这里使用配置的 CLI 路径
  args,
  // ...
});
```

**如果使用 OpenAI 官方 CLI**:
```typescript
const args = [
  'api',
  'chat.completions.create',
  '-m', 'gpt-4',
  '--message', request.message,
];

const result = await spawnCli({
  command: 'openai',  // 或配置为 config.cli.openaiPath
  args,
  // ...
});
```

**如果使用自定义脚本**:
```typescript
const args = [
  request.message,
  '--thread', request.threadId,
];

const result = await spawnCli({
  command: 'python',
  args: ['scripts/gpt_wrapper.py', ...args],
  // ...
});
```

#### 修改 Minimax Provider

编辑 `src/agents/providers/minimaxProvider.ts`，类似修改。

### 方式四：直接使用 API（不用 CLI）

如果你想直接调用 API 而不是通过 CLI，需要修改 provider：

```typescript
// src/agents/providers/gpt52Provider.ts
import { AgentProvider, AgentRequest } from '../types';

export class GPT52Provider implements AgentProvider {
  name = 'gpt52-api';

  async invoke(request: AgentRequest) {
    const startTime = Date.now();

    // 直接调用 API
    const response = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${process.env.OPENAI_API_KEY}`,
      },
      body: JSON.stringify({
        model: 'gpt-4',
        messages: [{ role: 'user', content: request.message }],
      }),
    });

    const data = await response.json();
    const content = data.choices[0].message.content;

    return {
      content,
      metadata: {
        model: 'gpt-4',
        tokensUsed: data.usage?.total_tokens,
        duration: Date.now() - startTime,
      },
    };
  }
}
```

## 环境变量配置

完整的 `.env` 配置示例：

```bash
# 服务器配置
PORT=3000
NODE_ENV=development

# CLI 配置（根据你的实际情况选择）
CLI_TIMEOUT_MS=300000

# 方式一：使用 opencode CLI
CLI_OPENCODE_PATH=opencode

# 方式二：使用其他 CLI 工具
# CLI_GPT_PATH=gpt-cli
# CLI_MINIMAX_PATH=minimax-cli

# 方式三：使用 API（需要 API Key）
# OPENAI_API_KEY=sk-...
# MINIMAX_API_KEY=...

# 数据存储
DATA_DIR=./data
TRANSCRIPTS_DIR=./data/transcripts
```

## 测试配置

### 1. 测试健康检查
```bash
curl http://localhost:3000/health
```

### 2. 测试聊天接口（需要先配置好 CLI 或 API）
```bash
curl -X POST http://localhost:3000/api/chat \
  -H "Content-Type: application/json" \
  -d '{
    "threadId": "test-001",
    "userId": "user-123",
    "catId": "architect",
    "message": "Hello, test message",
    "model": "gpt52"
  }'
```

### 3. 查看错误日志
如果调用失败，检查：
- 服务器日志：`tail -f server.log`
- Transcript 文件：`cat data/transcripts/*.jsonl`

## 常见问题

### Q: opencode 命令找不到
**A**:
1. 检查是否已安装：`which opencode` 或 `where opencode`
2. 如果未安装，按照 opencode 官方文档安装
3. 或者修改 `.env` 中的 `CLI_OPENCODE_PATH` 为完整路径

### Q: CLI 调用超时
**A**:
1. 增加超时时间：`.env` 中设置 `CLI_TIMEOUT_MS=600000`（10分钟）
2. 检查 CLI 命令是否正确：手动运行测试
3. 查看 stderr 输出：检查 `data/transcripts/*.jsonl` 中的错误事件

### Q: 想使用不同的模型
**A**:
1. 修改对应的 provider 文件（`src/agents/providers/*.ts`）
2. 更新 CLI 命令参数
3. 在 `src/schemas/chat.ts` 中添加新的 model 枚举值

### Q: 不想用 CLI，想直接用 SDK
**A**:
1. 安装对应的 SDK：`npm install openai` 或 `npm install @anthropic-ai/sdk`
2. 修改 provider 代码，替换 `spawnCli()` 为 SDK 调用
3. 参考上面"方式四"的示例代码

## 下一步

1. **配置你的 CLI 工具**：根据实际使用的工具修改配置
2. **测试端到端流程**：发送测试请求，验证完整流程
3. **查看 transcript**：检查 `data/transcripts/` 目录下的日志文件
4. **扩展功能**：根据需要添加新的模型或功能
