# 🚀 Deploy Flutter App to Firebase Hosting
# This script builds and deploys the inventory management system

Write-Host "🔨 Building Flutter Web App..." -ForegroundColor Yellow
flutter build web

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Build successful! Deploying to Firebase Hosting..." -ForegroundColor Green
    firebase deploy --only hosting
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "🎉 Deployment successful!" -ForegroundColor Green
        Write-Host "🌐 Live URL: https://inventory-management-aefea.web.app" -ForegroundColor Cyan
        Write-Host "🔑 Admin Login: admin@mit.edu / MITAdmin123!" -ForegroundColor Cyan
    } else {
        Write-Host "❌ Deployment failed!" -ForegroundColor Red
    }
} else {
    Write-Host "❌ Build failed!" -ForegroundColor Red
}

Write-Host "Press any key to continue..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")