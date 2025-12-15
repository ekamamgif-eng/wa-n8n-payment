# Setup Neon DB Schema
# PowerShell script untuk create tables di Neon DB

Write-Host "🗄️  Setting up Neon DB Schema..." -ForegroundColor Cyan

# Check if psql is installed
$psqlInstalled = Get-Command psql -ErrorAction SilentlyContinue
if (-not $psqlInstalled) {
    Write-Host "❌ psql not found!" -ForegroundColor Red
    Write-Host "📥 Install PostgreSQL client:" -ForegroundColor Yellow
    Write-Host "   Windows: https://www.postgresql.org/download/windows/" -ForegroundColor Gray
    Write-Host "   Or use Docker:" -ForegroundColor Yellow
    Write-Host "   docker run --rm -it postgres:15 psql 'your-connection-string'" -ForegroundColor Gray
    exit 1
}

Write-Host "✅ psql found" -ForegroundColor Green

# Load connection string from .env
if (Test-Path ".env") {
    Write-Host "📄 Loading connection from .env..." -ForegroundColor Cyan
    
    $envContent = Get-Content ".env"
    $dbHost = ($envContent | Select-String "NEON_DB_HOST=(.+)" | ForEach-Object { $_.Matches.Groups[1].Value }).Trim()
    $port = ($envContent | Select-String "NEON_DB_PORT=(.+)" | ForEach-Object { $_.Matches.Groups[1].Value }).Trim()
    $dbname = ($envContent | Select-String "NEON_DB_NAME=(.+)" | ForEach-Object { $_.Matches.Groups[1].Value }).Trim()
    $user = ($envContent | Select-String "NEON_DB_USER=(.+)" | ForEach-Object { $_.Matches.Groups[1].Value }).Trim()
    $password = ($envContent | Select-String "NEON_DB_PASSWORD=(.+)" | ForEach-Object { $_.Matches.Groups[1].Value }).Trim()
    
    $connectionString = "postgresql://${user}:${password}@${dbHost}:${port}/${dbname}?sslmode=require"
}
else {
    Write-Host "❌ .env file not found!" -ForegroundColor Red
    Write-Host "💡 Copy .env.example to .env first" -ForegroundColor Yellow
    exit 1
}

# Test connection
Write-Host "🔌 Testing connection to Neon DB..." -ForegroundColor Cyan
$testResult = psql $connectionString -c "SELECT version();" 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Connection failed!" -ForegroundColor Red
    Write-Host $testResult -ForegroundColor Red
    exit 1
}

Write-Host "✅ Connection successful" -ForegroundColor Green

# Run schema.sql
Write-Host "📝 Creating tables..." -ForegroundColor Cyan

if (Test-Path "database\schema.sql") {
    $result = psql $connectionString -f "database\schema.sql" 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Schema created successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "❌ Schema creation failed!" -ForegroundColor Red
        Write-Host $result -ForegroundColor Red
        exit 1
    }
}
else {
    Write-Host "❌ database\schema.sql not found!" -ForegroundColor Red
    exit 1
}

# Verify tables
Write-Host "🔍 Verifying tables..." -ForegroundColor Cyan
$tables = psql $connectionString -c "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name;" -t

Write-Host "📊 Tables created:" -ForegroundColor Green
Write-Host $tables -ForegroundColor Gray

Write-Host ""
Write-Host "✅ Neon DB setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Next steps:" -ForegroundColor Yellow
Write-Host "1. Start n8n: .\scripts\start.ps1" -ForegroundColor White
Write-Host "2. Import workflow" -ForegroundColor White
Write-Host "3. Configure PostgreSQL credentials in n8n" -ForegroundColor White
Write-Host ""
