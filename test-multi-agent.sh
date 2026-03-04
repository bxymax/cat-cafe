#!/bin/bash

# Test multi-agent conversation
BASE_URL="http://localhost:3000"
THREAD_ID="thread-multi-agent-001"
USER_ID="user-test"

echo "=== Cat Café Multi-Agent Test ==="
echo ""

# Test 1: User talks to architect
echo "1. User -> Architect"
curl -s -X POST "$BASE_URL/api/chat" \
  -H "Content-Type: application/json" \
  -d "{
    \"threadId\": \"$THREAD_ID\",
    \"userId\": \"$USER_ID\",
    \"catId\": \"architect\",
    \"message\": \"Let's design a new feature. @developer what do you think?\",
    \"model\": \"openai/gpt52\"
  }" | jq '.response' 2>/dev/null || echo "Failed"

echo ""
echo "2. User -> Developer"
curl -s -X POST "$BASE_URL/api/chat" \
  -H "Content-Type: application/json" \
  -d "{
    \"threadId\": \"$THREAD_ID\",
    \"userId\": \"$USER_ID\",
    \"catId\": \"developer\",
    \"message\": \"I'll implement it. @frontend can you handle the UI?\",
    \"model\": \"openai/gpt52\"
  }" | jq '.response' 2>/dev/null || echo "Failed"

echo ""
echo "3. User -> Frontend"
curl -s -X POST "$BASE_URL/api/chat" \
  -H "Content-Type: application/json" \
  -d "{
    \"threadId\": \"$THREAD_ID\",
    \"userId\": \"$USER_ID\",
    \"catId\": \"frontend\",
    \"message\": \"Sure, I'll make it beautiful!\",
    \"model\": \"minimax/minimax-m2.5\"
  }" | jq '.response' 2>/dev/null || echo "Failed"

echo ""
echo "4. Get thread context"
curl -s -X GET "$BASE_URL/api/thread/$THREAD_ID" | jq '.' 2>/dev/null || echo "Failed"
