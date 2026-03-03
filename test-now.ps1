Write-Host "Testing Cat Cafe API..." -ForegroundColor Yellow
$body = '{"threadId":"thread-005","userId":"user-test","catId":"architect","message":"请用中文说：你好，我是 AI 助手！","model":"openai/gpt52"}'
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/api/chat" -Method POST -ContentType "application/json" -Body $body -UseBasicParsing -TimeoutSec 120
    Write-Host "Success!" -ForegroundColor Green
    $response.Content
} catch {
    Write-Host "Failed: $_" -ForegroundColor Red
}
