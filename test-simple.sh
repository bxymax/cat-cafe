#!/bin/bash

echo "==================================="
echo "Cat Cafe Runtime - API 测试"
echo "==================================="
echo ""

# 测试健康检查
echo "1. 测试健康检查端点..."
HEALTH_RESPONSE=$(curl -s http://localhost:3000/health)
if [ $? -eq 0 ] && echo "$HEALTH_RESPONSE" | grep -q "ok"; then
    echo "✓ 健康检查成功"
    echo "$HEALTH_RESPONSE"
else
    echo "✗ 健康检查失败"
    echo "$HEALTH_RESPONSE"
    exit 1
fi

echo ""
echo "2. 测试输入验证（缺少必填字段）..."
VALIDATION_RESPONSE=$(curl -s -X POST http://localhost:3000/api/chat \
  -H "Content-Type: application/json" \
  -d '{"threadId": "test"}')

if echo "$VALIDATION_RESPONSE" | grep -q "Invalid request"; then
    echo "✓ 输入验证正常工作"
    echo "$VALIDATION_RESPONSE"
else
    echo "✗ 输入验证失败"
    echo "$VALIDATION_RESPONSE"
fi

echo ""
echo "3. 测试完整聊天请求..."
CHAT_RESPONSE=$(curl -s -X POST http://localhost:3000/api/chat \
  -H "Content-Type: application/json" \
  -d '{
    "threadId": "test-thread-001",
    "userId": "test-user",
    "catId": "architect",
    "message": "你好，这是一个测试消息",
    "model": "openai/gpt52"
  }')

if echo "$CHAT_RESPONSE" | grep -q '"success":true'; then
    echo "✓ 聊天接口工作正常"
    echo "$CHAT_RESPONSE"
elif echo "$CHAT_RESPONSE" | grep -q "error"; then
    echo "⚠ 聊天接口返回错误"
    echo "$CHAT_RESPONSE"
    echo ""
    echo "可能的原因："
    echo "1. opencode CLI 路径配置错误"
    echo "2. opencode CLI 未正确安装"
    echo "3. 模型名称不正确"
else
    echo "✗ 未知响应"
    echo "$CHAT_RESPONSE"
fi

echo ""
echo "4. 检查 transcript 文件..."
if [ -d "data/transcripts" ]; then
    FILE_COUNT=$(find data/transcripts -name "*.jsonl" 2>/dev/null | wc -l)
    echo "✓ Transcript 目录存在，包含 $FILE_COUNT 个文件"
    if [ $FILE_COUNT -gt 0 ]; then
        echo ""
        echo "最新的 transcript 记录："
        tail -5 data/transcripts/*.jsonl 2>/dev/null
    fi
else
    echo "⚠ Transcript 目录不存在"
fi

echo ""
echo "==================================="
echo "测试完成"
echo "==================================="
