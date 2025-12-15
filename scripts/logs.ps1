# View n8n logs
Write-Host "📋 Viewing n8n logs..." -ForegroundColor Cyan
Write-Host "Press Ctrl+C to exit" -ForegroundColor Gray
Write-Host ""

docker-compose logs -f n8n
