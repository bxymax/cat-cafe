$body = @"
{"threadId":"thread-007","userId":"user-test","catId":"architect","message":"who are you?","model":"openai/gpt52"}
"@

Write-Host "Sending request..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/api/chat" -Method POST -ContentType "application/json" -Body $body -UseBasicParsing -TimeoutSec 120
    Write-Host "Success!" -ForegroundColor Green
    $json = $response.Content | ConvertFrom-Json
    Write-Host "Response: $($json.response)" -ForegroundColor Cyan
    Write-Host "Model: $($json.metadata.model)" -ForegroundColor Gray
    Write-Host "Duration: $($json.metadata.duration)ms" -ForegroundColor Gray
} catch {
    Write-Host "Failed!" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}
