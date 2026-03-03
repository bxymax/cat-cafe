$body = '{"threadId":"test-004","userId":"user-test","catId":"architect","message":"Say hello in Chinese","model":"openai/gpt52"}'
$response = Invoke-WebRequest -Uri "http://localhost:3000/api/chat" -Method POST -ContentType "application/json" -Body $body -UseBasicParsing -TimeoutSec 120
$response.Content
