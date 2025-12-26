# Claude Code Sandbox Rebuild Script for Windows
# Use this to rebuild the container after Dockerfile changes

$ErrorActionPreference = "Stop"

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Claude Code Sandbox - Rebuild" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Check if credentials exist and warn user
if (Test-Path "claude-credentials\.credentials.json") {
    Write-Host "INFO: Claude credentials found - they will be preserved" -ForegroundColor Green
    Write-Host "      Your authentication should persist after rebuild" -ForegroundColor Green
    Write-Host ""
}

# Check if container is running
$running = docker ps -q -f name=claude-code-sandbox 2>$null

if ($running) {
    Write-Host "Stopping running container..." -ForegroundColor Yellow
    docker-compose down
    Write-Host ""
}

Write-Host "Rebuilding Docker container (no cache)..." -ForegroundColor Cyan
Write-Host "This may take a few minutes..." -ForegroundColor Gray
Write-Host ""

docker-compose build --no-cache

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "[OK] Rebuild complete!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  .\start.ps1              # Start the container"
    Write-Host "  .\shell.ps1              # Enter the container shell"
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "[ERROR] Rebuild failed. Please check the error messages above." -ForegroundColor Red
    exit 1
}
