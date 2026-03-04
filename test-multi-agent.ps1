$BASE_URL = "http://localhost:3000"
$THREAD_ID = "thread-multi-agent-001"
$USER_ID = "user-test"

Write-Host "=== Cat Café Multi-Agent Test ===" -ForegroundColor Cyan
Write-Host ""

# Test 1: User talks to architect
Write-Host "1. User -> Architect (asking developer to join)" -ForegroundColor Yellow
$body1 = @{
    threadId = $THREAD_ID
    userId = $USER_ID
    catId = "architect"
    message = "Let's design a new feature. @developer what do you think?"
    model = "openai/gpt52"
} | ConvertTo-Json

try {
    $response1 = Invoke-WebRequest -Uri "$BASE_URL/api/chat" -Method POST -ContentType "application/json" -Body $body1 -UseBasicParsing -TimeoutSec 120
    $json1 = $response1.Content | ConvertFrom-Json
    Write-Host "Architect: $($json1.response)" -ForegroundColor Green
    if ($json1.a2aResponses.developer) {
        Write-Host "Developer (A2A): $($json1.a2aResponses.developer)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "Failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 2: User talks to developer
Write-Host "2. User -> Developer (asking frontend to join)" -ForegroundColor Yellow
$body2 = @{
    threadId = $THREAD_ID
    userId = $USER_ID
    catId = "developer"
    message = "I'll implement it. @frontend can you handle the UI?"
    model = "openai/gpt52"
} | ConvertTo-Json

try {
    $response2 = Invoke-WebRequest -Uri "$BASE_URL/api/chat" -Method POST -ContentType "application/json" -Body $body2 -UseBasicParsing -TimeoutSec 120
    $json2 = $response2.Content | ConvertFrom-Json
    Write-Host "Developer: $($json2.response)" -ForegroundColor Green
    if ($json2.a2aResponses.frontend) {
        Write-Host "Frontend (A2A): $($json2.a2aResponses.frontend)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "Failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 3: User talks to frontend
Write-Host "3. User -> Frontend" -ForegroundColor Yellow
$body3 = @{
    threadId = $THREAD_ID
    userId = $USER_ID
    catId = "frontend"
    message = "Sure, I'll make it beautiful!"
    model = "minimax/minimax-m2.5"
} | ConvertTo-Json

try {
    $response3 = Invoke-WebRequest -Uri "$BASE_URL/api/chat" -Method POST -ContentType "application/json" -Body $body3 -UseBasicParsing -TimeoutSec 120
    $json3 = $response3.Content | ConvertFrom-Json
    Write-Host "Frontend: $($json3.response)" -ForegroundColor Green
} catch {
    Write-Host "Failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 4: Get thread context
Write-Host "4. Get thread context" -ForegroundColor Yellow
try {
    $response4 = Invoke-WebRequest -Uri "$BASE_URL/api/thread/$THREAD_ID" -Method GET -UseBasicParsing -TimeoutSec 30
    $json4 = $response4.Content | ConvertFrom-Json
    Write-Host "Thread has $($json4.messages.Count) messages:" -ForegroundColor Green
    foreach ($msg in $json4.messages) {
        Write-Host "  [$($msg.catId)] $($msg.content.Substring(0, [Math]::Min(50, $msg.content.Length)))..." -ForegroundColor Gray
    }
} catch {
    Write-Host "Failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Test Complete ===" -ForegroundColor Cyan
