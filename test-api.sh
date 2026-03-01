#!/bin/bash

echo "Testing Cat Cafe Runtime API"
echo "=============================="
echo ""

# Test health endpoint
echo "1. Testing health endpoint..."
curl -s http://localhost:3000/health | jq .
echo ""

# Test chat endpoint with valid request
echo "2. Testing chat endpoint (will fail without opencode CLI)..."
curl -s -X POST http://localhost:3000/api/chat \
  -H "Content-Type: application/json" \
  -d '{
    "threadId": "test-thread-001",
    "userId": "test-user",
    "catId": "architect",
    "message": "Hello, architect cat!",
    "model": "gpt52"
  }' | jq .
echo ""

# Test chat endpoint with invalid request
echo "3. Testing validation (missing required field)..."
curl -s -X POST http://localhost:3000/api/chat \
  -H "Content-Type: application/json" \
  -d '{
    "threadId": "test-thread-001",
    "userId": "test-user"
  }' | jq .
echo ""

echo "Tests complete!"
