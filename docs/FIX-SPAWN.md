# 修复：CLI 子进程调用问题

## 问题描述

使用真实 AI 模型时报错：
```
Error: CLI process exited with code 1: Error: Unable to connect. Is the computer able to access the url?
```

但直接在终端运行 `opencode run --model openai/gpt-5.2 "测试"` 是正常的。

## 根本原因

Node.js `spawn()` 调用 Windows 可执行文件时的配置问题：

1. **使用了 `shell: true`**
   - 导致安全警告和参数转义问题
   - 在某些情况下会导致进程卡死

2. **stdin 设置为 `'ignore'`**
   - OpenCode CLI 需要 stdin 管道
   - 即使不发送数据，也需要提供 pipe 并关闭

3. **缺少环境变量继承**
   - OpenCode 的 OAuth token 存储在环境变量中
   - 子进程需要继承父进程的 `process.env`

## 解决方案

修改 `src/runtime/spawnCli.ts`：

```typescript
proc = spawn(command, args, {
  stdio: ['pipe', 'pipe', 'pipe'], // ✅ 改为 pipe
  env: process.env,                 // ✅ 继承环境变量
  cwd: cwd || process.cwd(),        // ✅ 支持自定义工作目录
  // ❌ 移除 shell: true
});

// ✅ 立即关闭 stdin
if (proc.stdin) {
  proc.stdin.end();
}
```

## 验证步骤

### 1. 单元测试

```bash
node test-spawn.js
```

预期输出：
```
Testing opencode spawn...
[stdout] 你好！...
Exit code: 0
Stdout length: > 0
```

### 2. API 测试

```bash
chmod +x test-fixed-spawn.sh
./test-fixed-spawn.sh
```

预期输出：
```
1️⃣  Testing 布偶猫 with GPT-5.2...
✅ Success!
Response: ...
CatId: architect

2️⃣  Testing 缅因猫 with GPT-5.2...
✅ Success!
CatId: developer

3️⃣  Testing 暹罗猫 with MiniMax-M2.5...
✅ Success!
CatId: frontend
```

### 3. Web 界面测试

1. 重启服务器：`npm run dev`
2. 刷新浏览器：http://localhost:3000
3. 点击不同的猫猫徽章
4. 发送消息，验证响应

## 技术细节

### Windows 进程启动

在 Windows 上，Node.js 的 `spawn()` 有特殊行为：

- **不使用 shell**：直接启动 .exe 文件，更快更安全
- **stdio 配置**：某些 CLI 工具需要 stdin pipe，即使不发送数据
- **环境变量**：默认不继承，需要显式传递 `env: process.env`

### OpenCode CLI 特性

- 使用 OAuth 认证，token 存储在环境变量或配置文件
- 需要 stdin 管道（即使是非交互模式）
- 输出 NDJSON 格式到 stdout

## 相关文件

- `src/runtime/spawnCli.ts` - 子进程管理（已修复）
- `src/agents/providers/gpt52Provider.ts` - GPT-5.2 提供者
- `src/agents/providers/minimaxProvider.ts` - MiniMax 提供者
- `test-spawn.js` - 单元测试
- `test-fixed-spawn.sh` - 集成测试

---

*修复时间：2026-03-06 01:00*
