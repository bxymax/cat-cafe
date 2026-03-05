#!/bin/bash

# Test the fixed spawn implementation

API_URL="http://localhost:3000/api"
THREAD_ID="fix-test-$(date +%s)"
USER_ID="test-user"

echo "=== Testing Fixed Spawn Implementation ==="
echo ""

# Test 1: 布偶猫
echo "1️⃣  Testing 布偶猫 with GPT-5.2..."
RESPONSE=$(curl -s -X POST "$API_URL/chat" \
  -H "Content-Type: application/json" \
  -d "{
    \"threadId\": \"$THREAD_ID\",
    \"userId\": \"$USER_ID\",
    \"catId\": \"architect\",
    \"message\": \"你好，请用一句话介绍你自己\",
    \"model\": \"openai/gpt52\"
  }")

if echo "$RESPONSE" | jq -e '.success' > /dev/null 2>&1; then
  echo "✅ Success!"
  echo "Response: $(echo "$RESPONSE" | jq -r '.response' | head -3)"
  echo "Model: $(echo "$RESPONSE" | jq -r '.metadata.model')"
  echo "CatId: $(echo "$RESPONSE" | jq -r '.metadata.catId')"
else
  echo "❌ Failed!"
  echo "$RESPONSE" | jq .
fi

echo ""
echo "---"
echo ""

# Test 2: 缅因猫
echo "2️⃣  Testing 缅因猫 with GPT-5.2..."
RESPONSE=$(curl -s -X POST "$API_URL/chat" \
  -H "Content-Type: application/json" \
  -d "{
    \"threadId\": \"$THREAD_ID\",
    \"userId\": \"$USER_ID\",
    \"catId\": \"developer\",
    \"message\": \"你好，请用一句话介绍你自己\",
    \"model\": \"openai/gpt52\"
  }")

if echo "$RESPONSE" | jq -e '.success' > /dev/null 2>&1; then
  echo "✅ Success!"
  echo "Response: $(echo "$RESPONSE" | jq -r '.response' | head -3)"
  echo "CatId: $(echo "$RESPONSE" | jq -r '.metadata.catId')"
else
  echo "❌ Failed!"
  echo "$RESPONSE" | jq .
fi

echo ""
echo "---"
echo ""

# Test 3: 暹罗猫
echo "3️⃣  Testing 暹罗猫 with MiniMax-M2.5..."
RESPONSE=$(curl -s -X POST "$API_URL/chat" \
  -H "Content-Type: application/json" \
  -d "{
    \"threadId\": \"$THREAD_ID\",
    \"userId\": \"$USER_ID\",
    \"catId\": \"frontend\",
    \"message\": \"你好，请用一句话介绍你自己\",
    \"model\": \"minimax/minimax-m2.5\"
  }")

if echo "$RESPONSE" | jq -e '.success' > /dev/null 2>&1; then
  echo "✅ Success!"
  echo "Response: $(echo "$RESPONSE" | jq -r '.response' | head -3)"
  echo "CatId: $(echo "$RESPONSE" | jq -r '.metadata.catId')"
else
  echo "❌ Failed!"
  echo "$RESPONSE" | jq .
fi

echo ""
echo "=== Tests Complete ==="
