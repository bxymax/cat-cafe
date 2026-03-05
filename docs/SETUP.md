# Cat Café 环境配置指南

## 快速开始（Mock 模式）

当前系统默认使用 **Mock Provider**，无需配置即可运行：

```bash
npm run dev
```

访问 http://localhost:3000 即可体验三猫协作（模拟响应）。

---

## 启用真实 AI 模型

### 1. 配置 OpenCode CLI

确保 OpenCode CLI 已安装并配置：

```bash
# 检查 CLI 版本
C:\Users\bai\.opencode\bin\opencode.exe --version

# 配置 OpenAI API Key
opencode config set OPENAI_API_KEY your_api_key_here
```

### 2. 验证模型可用性

```bash
# 列出可用模型
opencode models list | grep gpt

# 测试模型调用
opencode run --model openai/gpt-4o-mini "hello"
```

### 3. 启用真实 Provider

编辑 `src/agents/registry.ts`：

```typescript
constructor() {
  // 启用真实 providers
  this.registerProvider('openai/gpt52', new GPT52Provider());
  this.registerProvider('minimax/minimax-m2.5', new MinimaxProvider());

  // Mock provider 作为 fallback
  const mockProvider = new MockProvider();
  this.registerProvider('mock', mockProvider);
}
```

### 4. 更新模型名称

根据 OpenCode 支持的模型，更新 `src/agents/providers/gpt52Provider.ts`：

```typescript
const args = [
  'run',
  '--model', 'openai/gpt-4o-mini',  // 或其他可用模型
  '--title', `${request.userId}_${request.catId}_${request.threadId}`,
  request.message,
];
```

---

## 常见问题

### Q: 为什么使用 Mock Provider？

A: 因为 OpenCode CLI 需要正确配置 API Key 和模型。Mock Provider 让你无需配置即可测试系统功能。

### Q: 如何切换回 Mock 模式？

A: 在 `src/agents/registry.ts` 中注释掉真实 provider，使用 mock provider 即可。

### Q: 支持哪些模型？

A: 当前支持：
- OpenAI GPT 系列（通过 OpenCode CLI）
- MiniMax M2.5（需要配置）
- Mock Provider（内置，无需配置）

---

*最后更新：2026-03-05*
