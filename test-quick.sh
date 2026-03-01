#!/bin/bash

echo "==================================="
echo "Cat Cafe Runtime - 快速测试"
echo "==================================="
echo ""

# 检查服务器是否运行
echo "1. 检查服务器状态..."
if curl -s http://localhost:3000/health > /dev/null 2>&1; then
    echo "✓ 服务器正在运行"
    curl -s http://localhost:3000/health | jq .
else
    echo "✗ 服务器未运行，请先启动: npm run dev"
    exit 1
fi

echo ""
echo "2. 测试输入验证..."
RESPONSE=$(curl -s -X POST http://localhost:3000/api/chat \
  -H "Content-Type: application/json" \
  -d '{"threadId": "test"}')

if echo "$RESPONSE" | grep -q "Invalid request"; then
    echo "✓ 输入验证正常工作"
    echo "$RESPONSE" | jq .
else
    echo "✗ 输入验证失败"
    echo "$RESPONSE"
fi

echo ""
echo "3. 测试完整聊天请求（需要配置 CLI）..."
RESPONSE=$(curl -s -X POST http://localhost:3000/api/chat \
  -H "Content-Type: application/json" \
  -d '{
    "threadId": "test-001",
    "userId": "user-123",
    "catId": "architect",
    "message": "Hello, this is a test",
    "model": "gpt52"
  }')

if echo "$RESPONSE" | grep -q "success"; then
    echo "✓ 聊天接口工作正常"
    echo "$RESPONSE" | jq .
else
    echo "⚠ 聊天接口返回错误（可能是 CLI 未配置）"
    echo "$RESPONSE" | jq .
fi

echo ""
echo "4. 检查 transcript 文件..."
if [ -d "data/transcripts" ]; then
    FILE_COUNT=$(ls -1 data/transcripts/*.jsonl 2>/dev/null | wc -l)
    echo "✓ Transcript 目录存在，包含 $FILE_COUNT 个文件"
    if [ $FILE_COUNT -gt 0 ]; then
        echo "最新的 transcript 内容："
        tail -3 data/transcripts/*.jsonl | head -10
    fi
else
    echo "⚠ Transcript 目录不存在"
fi

echo ""
echo "==================================="
echo "测试完成！"
echo "==================================="
echo ""
echo "下一步："
echo "1. 配置 opencode CLI（参考 OPENCODE_CONFIG.md）"
echo "2. 或修改 provider 使用你的 CLI 工具"
echo "3. 重新测试聊天接口"
