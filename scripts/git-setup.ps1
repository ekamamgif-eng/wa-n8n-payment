# Git Setup and Push to GitHub
# PowerShell script

Write-Host "🚀 Preparing for GitHub..." -ForegroundColor Cyan

# Check if git is installed
$gitInstalled = Get-Command git -ErrorAction SilentlyContinue
if (-not $gitInstalled) {
    Write-Host "❌ Git not installed!" -ForegroundColor Red
    Write-Host "📥 Download from: https://git-scm.com/download/win" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Git found" -ForegroundColor Green

# Check if already initialized
if (Test-Path ".git") {
    Write-Host "⚠️  Git repository already initialized" -ForegroundColor Yellow
    $reinit = Read-Host "Reinitialize? (y/n)"
    if ($reinit -eq "y") {
        Remove-Item -Recurse -Force ".git"
        git init
        Write-Host "✅ Repository reinitialized" -ForegroundColor Green
    }
    else {
        Write-Host "Skipping initialization..." -ForegroundColor Gray
    }
}
else {
    # Initialize git
    Write-Host "📁 Initializing git repository..." -ForegroundColor Cyan
    git init
    Write-Host "✅ Git initialized" -ForegroundColor Green
}

# Configure git (if not configured)
$userName = git config user.name

if (-not $userName) {
    Write-Host "⚙️  Git user not configured" -ForegroundColor Yellow
    $name = Read-Host "Enter your name"
    $email = Read-Host "Enter your email"
    git config user.name "$name"
    git config user.email "$email"
    Write-Host "✅ Git user configured" -ForegroundColor Green
}

# Add all files
Write-Host "📝 Adding files..." -ForegroundColor Cyan
git add .

# Show status
Write-Host "`n📊 Git Status:" -ForegroundColor Cyan
git status --short

# Commit
Write-Host "`n💾 Creating commit..." -ForegroundColor Cyan
git commit -m "Initial commit: WhatsApp Payment Processor with n8n, OpenAI, and Neon DB"

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Commit created" -ForegroundColor Green
}
else {
    Write-Host "⚠️  No changes to commit or commit failed" -ForegroundColor Yellow
}

# Ask for GitHub repository
Write-Host "`n🔗 GitHub Repository Setup" -ForegroundColor Cyan
Write-Host "1. Go to: https://github.com/new" -ForegroundColor White
Write-Host "2. Repository name: wa-n8n-payment" -ForegroundColor White
Write-Host "3. Description: WhatsApp Payment Proof Processor using n8n, OpenAI, and Neon DB" -ForegroundColor White
Write-Host "4. Public or Private: Your choice" -ForegroundColor White
Write-Host "5. Don't initialize with README" -ForegroundColor White
Write-Host "6. Create repository" -ForegroundColor White
Write-Host ""

$createRepo = Read-Host "Have you created the GitHub repository? (y/n)"

if ($createRepo -eq "y") {
    $username = Read-Host "Enter your GitHub username"
    $repoName = Read-Host "Enter repository name (default: wa-n8n-payment)"
    
    if (-not $repoName) {
        $repoName = "wa-n8n-payment"
    }
    
    $remoteUrl = "https://github.com/$username/$repoName.git"
    
    Write-Host "`n🔗 Adding remote..." -ForegroundColor Cyan
    
    # Remove existing remote if exists
    git remote remove origin 2>$null
    
    # Add new remote
    git remote add origin $remoteUrl
    Write-Host "✅ Remote added: $remoteUrl" -ForegroundColor Green
    
    # Set main branch
    Write-Host "`n🌿 Setting main branch..." -ForegroundColor Cyan
    git branch -M main
    
    # Push to GitHub
    Write-Host "`n📤 Pushing to GitHub..." -ForegroundColor Cyan
    Write-Host "You may be asked to login to GitHub..." -ForegroundColor Yellow
    
    git push -u origin main
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n✅ Successfully pushed to GitHub!" -ForegroundColor Green
        Write-Host "🌐 Repository URL: https://github.com/$username/$repoName" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "📋 Next steps:" -ForegroundColor Yellow
        Write-Host "1. Deploy to Railway: https://railway.app/" -ForegroundColor White
        Write-Host "2. Or deploy to Render: https://render.com/" -ForegroundColor White
        Write-Host "3. See RAILWAY-DEPLOY.md for detailed guide" -ForegroundColor White
    }
    else {
        Write-Host "`n❌ Push failed!" -ForegroundColor Red
        Write-Host "💡 Make sure:" -ForegroundColor Yellow
        Write-Host "   - GitHub repository exists" -ForegroundColor Gray
        Write-Host "   - You have access to the repository" -ForegroundColor Gray
        Write-Host "   - GitHub credentials are correct" -ForegroundColor Gray
    }
}
else {
    Write-Host "`n📝 Manual push instructions:" -ForegroundColor Yellow
    Write-Host "1. Create GitHub repository" -ForegroundColor White
    Write-Host "2. Run these commands:" -ForegroundColor White
    Write-Host "   git remote add origin https://github.com/YOUR_USERNAME/wa-n8n-payment.git" -ForegroundColor Gray
    Write-Host "   git branch -M main" -ForegroundColor Gray
    Write-Host "   git push -u origin main" -ForegroundColor Gray
}

Write-Host "`n✅ Git setup complete!" -ForegroundColor Green
