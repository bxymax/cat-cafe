# 修复完成 - 2026-03-06

## ✅ 已修复的问题

### 1. 启用真实 AI 模型

**修改**：
- `src/agents/registry.ts` - 恢复使用 GPT52Provider 和 MinimaxProvider
- `src/agents/providers/gpt52Provider.ts` - 使用 `openai/gpt-5.2` 模型
- `src/agents/providers/minimaxProvider.ts` - 添加 catId 到 metadata，改进错误处理

**验证**：
```bash
# 测试 GPT-5.2
opencode run --model openai/gpt-5.2 "你好"

# 测试 MiniMax
opencode run --model minimax-cn/MiniMax-M2.5 "你好"
```

两个模型都已验证可用！

---

### 2. 统一猫猫名称

**修改**：
- 头部徽章：`🎨 布偶猫` / `💻 缅因猫` / `🎭 暹罗猫`
- 消息头部：`🎨 布偶猫` / `💻 缅因猫` / `🎭 暹罗猫`
- @ 提及下拉框：`@布偶猫` / `@缅因猫` / `@暹罗猫`

现在所有地方都使用统一的猫猫名字，不再混用"架构师"/"开发者"/"前端"。

---

### 3. 添加调试日志

**新增**：
- 点击猫猫徽章时输出：`Selected cat: architect`
- 发送消息时输出：`Sending to cat: developer`
- 收到响应时输出：`Response from: frontend`

打开浏览器控制台可以看到当前选择的猫猫。

---

## 🧪 测试方法

### 方式 1：Web 界面

1. 刷新浏览器页面 (http://localhost:3000)
2. 点击不同的猫猫徽章（布偶猫/缅因猫/暹罗猫）
3. 发送消息，观察响应
4. 打开控制台查看日志

### 方式 2：API 测试

```bash
chmod +x test-real-models.sh
./test-real-models.sh
```

---

## 📝 技术细节

### 模型配置

| 猫猫 | catId | 模型 | CLI 命令 |
|------|-------|------|----------|
| 🎨 布偶猫 | architect | openai/gpt52 | openai/gpt-5.2 |
| 💻 缅因猫 | developer | openai/gpt52 | openai/gpt-5.2 |
| 🎭 暹罗猫 | frontend | minimax/minimax-m2.5 | minimax-cn/MiniMax-M2.5 |

### 数据流

```
用户点击徽章 → currentCat 更新 → 发送消息
                                    ↓
                            POST /api/chat
                            { catId: currentCat }
                                    ↓
                            agentRegistry.getProvider(catId, model)
                                    ↓
                            GPT52Provider / MinimaxProvider
                                    ↓
                            spawnCli → opencode run
                                    ↓
                            返回响应 { content, metadata: { catId } }
```

---

## 🐛 如果还有问题

### 问题：点击徽章没反应

**检查**：
1. 打开浏览器控制台
2. 点击徽章，看是否输出 `Selected cat: xxx`
3. 如果没有输出，刷新页面重试

### 问题：所有猫回复都一样

**检查**：
1. 控制台查看 `Sending to cat: xxx`
2. 查看响应的 `metadata.catId`
3. 确认 catId 是否正确传递

### 问题：模型调用失败

**检查**：
```bash
# 验证 opencode 认证状态
opencode auth status

# 测试模型
opencode run --model openai/gpt-5.2 "test"
```

---

*修复完成时间：2026-03-06 00:30*
