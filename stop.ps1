# Stop Claude Code Sandbox
# Requires PowerShell 5.1 or later

$ErrorActionPreference = "Stop"

Write-Host "Stopping Claude Code Sandbox..." -ForegroundColor Cyan

# Check if container is running
$runningContainer = docker ps --filter "name=claude-code-sandbox" --format "{{.Names}}"
if ($runningContainer -ne "claude-code-sandbox") {
    Write-Host "[OK] Container is not running" -ForegroundColor Green
    exit 0
}

# Stop the container
docker-compose down

Write-Host "[OK] Container stopped successfully" -ForegroundColor Green
Write-Host ""
Write-Host "To start again, run:"
Write-Host "  .\start.ps1"
