#!/bin/bash

# Test all three cats with real models

API_URL="http://localhost:3000/api"
THREAD_ID="test-$(date +%s)"
USER_ID="test-user"

echo "=== Testing Cat Café with Real Models ==="
echo "Thread: $THREAD_ID"
echo ""

# Test 1: 布偶猫 (Architect)
echo "1️⃣  Testing 布偶猫 (architect) with GPT-5.2..."
RESPONSE=$(curl -s -X POST "$API_URL/chat" \
  -H "Content-Type: application/json" \
  -d "{
    \"threadId\": \"$THREAD_ID\",
    \"userId\": \"$USER_ID\",
    \"catId\": \"architect\",
    \"message\": \"你好，请介绍一下你自己\",
    \"model\": \"openai/gpt52\"
  }")

echo "Response:"
echo "$RESPONSE" | jq -r '.response' | head -5
echo "Metadata:"
echo "$RESPONSE" | jq '.metadata'
echo ""
echo "---"
echo ""

# Test 2: 缅因猫 (Developer)
echo "2️⃣  Testing 缅因猫 (developer) with GPT-5.2..."
RESPONSE=$(curl -s -X POST "$API_URL/chat" \
  -H "Content-Type: application/json" \
  -d "{
    \"threadId\": \"$THREAD_ID\",
    \"userId\": \"$USER_ID\",
    \"catId\": \"developer\",
    \"message\": \"你好，请介绍一下你自己\",
    \"model\": \"openai/gpt52\"
  }")

echo "Response:"
echo "$RESPONSE" | jq -r '.response' | head -5
echo "Metadata:"
echo "$RESPONSE" | jq '.metadata'
echo ""
echo "---"
echo ""

# Test 3: 暹罗猫 (Frontend)
echo "3️⃣  Testing 暹罗猫 (frontend) with MiniMax-M2.5..."
RESPONSE=$(curl -s -X POST "$API_URL/chat" \
  -H "Content-Type: application/json" \
  -d "{
    \"threadId\": \"$THREAD_ID\",
    \"userId\": \"$USER_ID\",
    \"catId\": \"frontend\",
    \"message\": \"你好，请介绍一下你自己\",
    \"model\": \"minimax/minimax-m2.5\"
  }")

echo "Response:"
echo "$RESPONSE" | jq -r '.response' | head -5
echo "Metadata:"
echo "$RESPONSE" | jq '.metadata'
echo ""

echo "=== All Tests Complete ==="
