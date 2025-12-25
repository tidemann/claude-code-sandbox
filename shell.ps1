# Enter Claude Code Sandbox shell
# Requires PowerShell 5.1 or later

$ErrorActionPreference = "Stop"

# Check if container is running
$runningContainer = docker ps --filter "name=claude-code-sandbox" --format "{{.Names}}"
if ($runningContainer -ne "claude-code-sandbox") {
    Write-Host "[ERROR] Container is not running" -ForegroundColor Red
    Write-Host ""
    Write-Host "Start the container first:"
    Write-Host "  .\start.ps1"
    exit 1
}

Write-Host "Entering Claude Code Sandbox shell..." -ForegroundColor Cyan
Write-Host "Type 'exit' to leave the container" -ForegroundColor Yellow
Write-Host ""

# Enter the container
docker-compose exec claude-code bash
