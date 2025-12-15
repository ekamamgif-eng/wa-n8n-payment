# Setup ngrok tunnel for WhatsApp webhook
Write-Host "🌐 Setting up ngrok tunnel..." -ForegroundColor Cyan

# Check if ngrok is installed
$ngrokInstalled = Get-Command ngrok -ErrorAction SilentlyContinue
if (-not $ngrokInstalled) {
    Write-Host "❌ ngrok tidak terinstall!" -ForegroundColor Red
    Write-Host "📥 Download: https://ngrok.com/download" -ForegroundColor Yellow
    exit 1
}

# Check if n8n is running
$n8nRunning = docker ps | Select-String "n8n-payment-processor"
if (-not $n8nRunning) {
    Write-Host "❌ n8n tidak berjalan!" -ForegroundColor Red
    exit 1
}

# Start ngrok
Write-Host "🚀 Starting ngrok..." -ForegroundColor Cyan
$ngrokJob = Start-Job -ScriptBlock { ngrok http 5678 }
Start-Sleep -Seconds 3

# Get URL
try {
    $ngrokApi = Invoke-RestMethod -Uri "http://localhost:4040/api/tunnels"
    $publicUrl = $ngrokApi.tunnels[0].public_url
    
    Write-Host "✅ Tunnel: $publicUrl" -ForegroundColor Green
    Write-Host "Webhook: $publicUrl/webhook/whatsapp-webhook" -ForegroundColor Cyan
    
    Receive-Job -Job $ngrokJob -Wait
}
catch {
    Write-Host "❌ Failed!" -ForegroundColor Red
    exit 1
}
