# Test Cat Cafe Runtime API

Write-Host "===================================" -ForegroundColor Cyan
Write-Host "Cat Cafe Runtime - API 测试" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: Health Check
Write-Host "1. 测试健康检查..." -ForegroundColor Yellow
try {
    $health = Invoke-WebRequest -Uri "http://localhost:3000/health" -UseBasicParsing
    Write-Host "✓ 健康检查成功" -ForegroundColor Green
    Write-Host $health.Content -ForegroundColor Gray
} catch {
    Write-Host "✗ 健康检查失败: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Test 2: Chat Endpoint
Write-Host "2. 测试聊天接口..." -ForegroundColor Yellow
$chatBody = @{
    threadId = "test-chat-001"
    userId = "test-user"
    catId = "architect"
    message = "请用中文回复：你好，我是 Cat Cafe 测试！"
    model = "openai/gpt52"
} | ConvertTo-Json

try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/api/chat" `
        -Method POST `
        -ContentType "application/json" `
        -Body $chatBody `
        -UseBasicParsing `
        -TimeoutSec 120

    $json = $response.Content | ConvertFrom-Json

    if ($json.success -eq $true) {
        Write-Host "✓ 聊天接口工作正常！" -ForegroundColor Green
        Write-Host ""
        Write-Host "AI 响应:" -ForegroundColor Cyan
        Write-Host $json.response -ForegroundColor White
        Write-Host ""
        Write-Host "元数据:" -ForegroundColor Gray
        Write-Host "  模型: $($json.metadata.model)"
        Write-Host "  耗时: $($json.metadata.duration)ms"
        Write-Host "  消息数: $($json.session.messageCount)"
    } else {
        Write-Host "⚠ 返回失败状态" -ForegroundColor Yellow
        Write-Host $response.Content
    }
} catch {
    Write-Host "✗ 聊天接口失败" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $errorBody = $reader.ReadToEnd()
        Write-Host $errorBody -ForegroundColor Red
    } else {
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}

Write-Host ""

# Test 3: Check Transcripts
Write-Host "3. 检查 transcript 文件..." -ForegroundColor Yellow
if (Test-Path "data/transcripts") {
    $files = Get-ChildItem "data/transcripts" -Filter "*.jsonl"
    Write-Host "✓ 找到 $($files.Count) 个 transcript 文件" -ForegroundColor Green

    if ($files.Count -gt 0) {
        Write-Host ""
        Write-Host "最新记录:" -ForegroundColor Cyan
        $latestFile = $files | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        Write-Host "  文件: $($latestFile.Name)" -ForegroundColor Gray
        Get-Content $latestFile.FullName -Tail 3 | ForEach-Object {
            try {
                $event = $_ | ConvertFrom-Json
                Write-Host "  [$($event.type)] $($event.content.Substring(0, [Math]::Min(50, $event.content.Length)))..." -ForegroundColor Gray
            } catch {
                Write-Host "  $_" -ForegroundColor Gray
            }
        }
    }
} else {
    Write-Host "⚠ Transcript 目录不存在" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "===================================" -ForegroundColor Cyan
Write-Host "测试完成！" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan
