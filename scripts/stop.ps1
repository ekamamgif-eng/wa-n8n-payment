# Stop all containers
Write-Host "🛑 Stopping containers..." -ForegroundColor Yellow
docker-compose down

Write-Host "✅ Containers stopped" -ForegroundColor Green
