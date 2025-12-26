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

# Enter the container with docker group access
docker-compose exec claude-code bash -c 'DOCKER_GID=$(stat -c "%g" /var/run/docker.sock 2>/dev/null || echo ""); if [ -n "$DOCKER_GID" ]; then exec sg $DOCKER_GID bash; else exec bash; fi'
