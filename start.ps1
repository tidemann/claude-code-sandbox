# Start Claude Code Sandbox
# Requires PowerShell 5.1 or later

$ErrorActionPreference = "Stop"

Write-Host "Starting Claude Code Sandbox..." -ForegroundColor Cyan

# Check if .env exists
if (-not (Test-Path .env)) {
    Write-Host "[ERROR] .env file not found" -ForegroundColor Red
    Write-Host "Please run .\setup.ps1 first to configure your credentials" -ForegroundColor Yellow
    exit 1
}

# Check if container is already running
$runningContainer = docker ps --filter "name=claude-code-sandbox" --format "{{.Names}}"
if ($runningContainer -eq "claude-code-sandbox") {
    Write-Host "[OK] Container is already running" -ForegroundColor Green
    Write-Host ""
    Write-Host "To access the shell, run:"
    Write-Host "  .\shell.ps1"
    exit 0
}

# Start the container
docker-compose up -d

# Wait for container to be ready
Write-Host "Waiting for container to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 2

# Check if container started successfully
$runningContainer = docker ps --filter "name=claude-code-sandbox" --format "{{.Names}}"
if ($runningContainer -eq "claude-code-sandbox") {
    Write-Host "[OK] Container started successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Container name: claude-code-sandbox" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Quick commands:" -ForegroundColor Cyan
    Write-Host "  .\shell.ps1              # Enter container shell"
    Write-Host "  .\stop.ps1               # Stop container"
    Write-Host "  .\logs.ps1               # View container logs"
    Write-Host ""
    Write-Host "Inside the container:" -ForegroundColor Cyan
    Write-Host "  git clone https://github.com/username/repo.git"
    Write-Host "  cd repo"
    Write-Host "  claude-code"
} else {
    Write-Host "[ERROR] Failed to start container" -ForegroundColor Red
    Write-Host "Check logs with: docker-compose logs" -ForegroundColor Yellow
    exit 1
}
