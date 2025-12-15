# WhatsApp Payment Processor - Start Script
# PowerShell script untuk Windows

Write-Host "🚀 Starting WhatsApp Payment Processor..." -ForegroundColor Cyan

# Check if .env exists
if (-not (Test-Path ".env")) {
    Write-Host "❌ File .env tidak ditemukan!" -ForegroundColor Red
    Write-Host "📝 Membuat .env dari template..." -ForegroundColor Yellow
    Copy-Item ".env.example" ".env"
    Write-Host "✅ File .env dibuat. Silakan edit file .env dengan konfigurasi Anda." -ForegroundColor Green
    Write-Host "📖 Baca README.md untuk panduan lengkap." -ForegroundColor Yellow
    exit 1
}

# Check if Docker is running
Write-Host "🐳 Checking Docker..." -ForegroundColor Cyan
$dockerRunning = docker info 2>&1 | Select-String "Server Version"
if (-not $dockerRunning) {
    Write-Host "❌ Docker tidak berjalan!" -ForegroundColor Red
    Write-Host "💡 Silakan start Docker Desktop terlebih dahulu." -ForegroundColor Yellow
    exit 1
}
Write-Host "✅ Docker is running" -ForegroundColor Green

# Pull latest n8n image
Write-Host "📦 Pulling latest n8n image..." -ForegroundColor Cyan
docker-compose pull

# Start containers
Write-Host "🔧 Starting containers..." -ForegroundColor Cyan
docker-compose up -d

# Wait for n8n to be ready
Write-Host "⏳ Waiting for n8n to be ready..." -ForegroundColor Cyan
Start-Sleep -Seconds 10

# Check if n8n is running
$n8nRunning = docker ps | Select-String "n8n-payment-processor"
if ($n8nRunning) {
    Write-Host "✅ n8n is running!" -ForegroundColor Green
    Write-Host ""
    Write-Host "🌐 Access n8n editor at: http://localhost:5678" -ForegroundColor Cyan
    Write-Host "👤 Username: admin (or check your .env)" -ForegroundColor Yellow
    Write-Host "🔑 Password: check N8N_BASIC_AUTH_PASSWORD in .env" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "📊 View logs:" -ForegroundColor Cyan
    Write-Host "   docker-compose logs -f n8n" -ForegroundColor Gray
    Write-Host ""
    Write-Host "🛑 Stop containers:" -ForegroundColor Cyan
    Write-Host "   docker-compose down" -ForegroundColor Gray
    Write-Host ""
} else {
    Write-Host "❌ Failed to start n8n!" -ForegroundColor Red
    Write-Host "📋 Check logs:" -ForegroundColor Yellow
    Write-Host "   docker-compose logs n8n" -ForegroundColor Gray
    exit 1
}

# Offer to show logs
$showLogs = Read-Host "📋 Show logs? (y/n)"
if ($showLogs -eq "y") {
    docker-compose logs -f n8n
}
