#!/bin/bash

# Test Cat Café Chat API with Mock Provider

API_URL="http://localhost:3000/api"
THREAD_ID="test-thread-$(date +%s)"
USER_ID="test-user"

echo "=== Testing Cat Café Chat API ==="
echo "Thread ID: $THREAD_ID"
echo ""

# Test 1: Chat with architect
echo "Test 1: 布偶猫 (Architect)"
curl -X POST "$API_URL/chat" \
  -H "Content-Type: application/json" \
  -d "{
    \"threadId\": \"$THREAD_ID\",
    \"userId\": \"$USER_ID\",
    \"catId\": \"architect\",
    \"message\": \"帮我设计一个用户认证系统\",
    \"model\": \"openai/gpt52\"
  }" | jq .

echo ""
echo "---"
echo ""

# Test 2: Chat with developer
echo "Test 2: 缅因猫 (Developer)"
curl -X POST "$API_URL/chat" \
  -H "Content-Type: application/json" \
  -d "{
    \"threadId\": \"$THREAD_ID\",
    \"userId\": \"$USER_ID\",
    \"catId\": \"developer\",
    \"message\": \"实现 JWT 认证\",
    \"model\": \"openai/gpt52\"
  }" | jq .

echo ""
echo "---"
echo ""

# Test 3: Chat with frontend
echo "Test 3: 暹罗猫 (Frontend)"
curl -X POST "$API_URL/chat" \
  -H "Content-Type: application/json" \
  -d "{
    \"threadId\": \"$THREAD_ID\",
    \"userId\": \"$USER_ID\",
    \"catId\": \"frontend\",
    \"message\": \"设计登录页面\",
    \"model\": \"minimax/minimax-m2.5\"
  }" | jq .

echo ""
echo "=== Tests Complete ==="
