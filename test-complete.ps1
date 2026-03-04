Write-Host "=== Cat Café 完整功能测试 ===" -ForegroundColor Cyan
Write-Host ""

$BASE_URL = "http://localhost:3000"
$THREAD_ID = "thread-final-test-$(Get-Date -Format 'yyyyMMddHHmmss')"
$USER_ID = "user-test"

# Test 1: Health check
Write-Host "1. 健康检查" -ForegroundColor Yellow
try {
    $health = Invoke-WebRequest -Uri "$BASE_URL/health" -Method GET -UseBasicParsing -TimeoutSec 5
    Write-Host "✓ 服务器运行正常" -ForegroundColor Green
} catch {
    Write-Host "✗ 服务器未响应: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Test 2: Architect chat
Write-Host "2. 架构师对话" -ForegroundColor Yellow
$body1 = @{
    threadId = $THREAD_ID
    userId = $USER_ID
    catId = "architect"
    message = "设计一个用户认证系统"
    model = "openai/gpt52"
} | ConvertTo-Json

try {
    $response1 = Invoke-WebRequest -Uri "$BASE_URL/api/chat" -Method POST -ContentType "application/json" -Body $body1 -UseBasicParsing -TimeoutSec 120
    $json1 = $response1.Content | ConvertFrom-Json
    if ($json1.success) {
        Write-Host "✓ 架构师响应: $($json1.response.Substring(0, [Math]::Min(100, $json1.response.Length)))..." -ForegroundColor Green
    } else {
        Write-Host "✗ 架构师响应失败: $($json1.error)" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ 请求失败: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 3: Developer chat with A2A
Write-Host "3. 开发者对话 (A2A 测试)" -ForegroundColor Yellow
$body2 = @{
    threadId = $THREAD_ID
    userId = $USER_ID
    catId = "developer"
    message = "我来实现后端逻辑。@frontend 你能设计UI吗？"
    model = "openai/gpt52"
} | ConvertTo-Json

try {
    $response2 = Invoke-WebRequest -Uri "$BASE_URL/api/chat" -Method POST -ContentType "application/json" -Body $body2 -UseBasicParsing -TimeoutSec 120
    $json2 = $response2.Content | ConvertFrom-Json
    if ($json2.success) {
        Write-Host "✓ 开发者响应: $($json2.response.Substring(0, [Math]::Min(100, $json2.response.Length)))..." -ForegroundColor Green
        if ($json2.a2aResponses.frontend) {
            Write-Host "✓ 前端 A2A 响应: $($json2.a2aResponses.frontend.Substring(0, [Math]::Min(100, $json2.a2aResponses.frontend.Length)))..." -ForegroundColor Cyan
        }
    } else {
        Write-Host "✗ 开发者响应失败: $($json2.error)" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ 请求失败: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 4: Get thread context
Write-Host "4. 获取线程上下文" -ForegroundColor Yellow
try {
    $response3 = Invoke-WebRequest -Uri "$BASE_URL/api/thread/$THREAD_ID" -Method GET -UseBasicParsing -TimeoutSec 30
    $json3 = $response3.Content | ConvertFrom-Json
    Write-Host "✓ 线程有 $($json3.messages.Count) 条消息" -ForegroundColor Green
    foreach ($msg in $json3.messages) {
        Write-Host "  [$($msg.catId)] $($msg.content.Substring(0, [Math]::Min(60, $msg.content.Length)))..." -ForegroundColor Gray
    }
} catch {
    Write-Host "✗ 获取线程失败: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 5: MCP Callback
Write-Host "5. MCP Callback 测试" -ForegroundColor Yellow
$body4 = @{
    threadId = $THREAD_ID
    catId = "architect"
    content = "[MCP Callback] 这是通过 MCP 回调发送的消息"
} | ConvertTo-Json

try {
    $response4 = Invoke-WebRequest -Uri "$BASE_URL/api/callbacks/post-message" -Method POST -ContentType "application/json" -Body $body4 -UseBasicParsing -TimeoutSec 30
    $json4 = $response4.Content | ConvertFrom-Json
    if ($json4.success) {
        Write-Host "✓ MCP Callback 成功" -ForegroundColor Green
    } else {
        Write-Host "✗ MCP Callback 失败" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ MCP Callback 失败: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== 测试完成 ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "前端界面: http://localhost:3000" -ForegroundColor Yellow
Write-Host "API 文档: http://localhost:3000/health" -ForegroundColor Yellow
