# Cat Cafe Runtime - API 测试脚本 (PowerShell)

Write-Host "===================================" -ForegroundColor Cyan
Write-Host "Cat Cafe Runtime - API 测试" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan
Write-Host ""

# 1. 测试健康检查
Write-Host "1. 测试健康检查端点..." -ForegroundColor Yellow
try {
    $healthResponse = Invoke-WebRequest -Uri "http://localhost:3000/health" -UseBasicParsing
    if ($healthResponse.StatusCode -eq 200) {
        Write-Host "✓ 健康检查成功" -ForegroundColor Green
        Write-Host $healthResponse.Content
    }
} catch {
    Write-Host "✗ 健康检查失败: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "2. 测试输入验证（缺少必填字段）..." -ForegroundColor Yellow
try {
    $body = @{
        threadId = "test"
    } | ConvertTo-Json

    $validationResponse = Invoke-WebRequest -Uri "http://localhost:3000/api/chat" `
        -Method POST `
        -ContentType "application/json" `
        -Body $body `
        -UseBasicParsing

    Write-Host "响应: $($validationResponse.Content)"
} catch {
    $errorResponse = $_.Exception.Response
    if ($errorResponse.StatusCode -eq 400) {
        Write-Host "✓ 输入验证正常工作（返回 400 错误）" -ForegroundColor Green
        $reader = New-Object System.IO.StreamReader($errorResponse.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host $responseBody
    } else {
        Write-Host "✗ 意外的错误: $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "3. 测试完整聊天请求..." -ForegroundColor Yellow
try {
    $chatBody = @{
        threadId = "test-thread-001"
        userId = "test-user"
        catId = "architect"
        message = "你好，这是一个测试消息"
        model = "openai/gpt52"
    } | ConvertTo-Json

    $chatResponse = Invoke-WebRequest -Uri "http://localhost:3000/api/chat" `
        -Method POST `
        -ContentType "application/json" `
        -Body $chatBody `
        -UseBasicParsing

    $content = $chatResponse.Content | ConvertFrom-Json

    if ($content.success -eq $true) {
        Write-Host "✓ 聊天接口工作正常" -ForegroundColor Green
        Write-Host "响应内容: $($content.response)"
        Write-Host "元数据: $($content.metadata | ConvertTo-Json -Compress)"
    } else {
        Write-Host "⚠ 聊天接口返回失败" -ForegroundColor Yellow
        Write-Host $chatResponse.Content
    }
} catch {
    Write-Host "⚠ 聊天接口返回错误" -ForegroundColor Yellow
    $errorResponse = $_.Exception.Response
    if ($errorResponse) {
        $reader = New-Object System.IO.StreamReader($errorResponse.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host $responseBody

        Write-Host ""
        Write-Host "可能的原因：" -ForegroundColor Yellow
        Write-Host "1. opencode CLI 路径配置错误"
        Write-Host "2. opencode CLI 未正确安装"
        Write-Host "3. 模型名称不正确"
        Write-Host "4. opencode CLI 执行失败"
    } else {
        Write-Host "错误: $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "4. 检查 transcript 文件..." -ForegroundColor Yellow
if (Test-Path "data/transcripts") {
    $files = Get-ChildItem "data/transcripts" -Filter "*.jsonl"
    Write-Host "✓ Transcript 目录存在，包含 $($files.Count) 个文件" -ForegroundColor Green

    if ($files.Count -gt 0) {
        Write-Host ""
        Write-Host "最新的 transcript 记录：" -ForegroundColor Cyan
        $files | ForEach-Object {
            Write-Host "文件: $($_.Name)" -ForegroundColor Gray
            Get-Content $_.FullName -Tail 3 | ForEach-Object {
                $json = $_ | ConvertFrom-Json
                Write-Host "  [$($json.type)] $($json.content)" -ForegroundColor Gray
            }
        }
    }
} else {
    Write-Host "⚠ Transcript 目录不存在" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "===================================" -ForegroundColor Cyan
Write-Host "测试完成" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan
