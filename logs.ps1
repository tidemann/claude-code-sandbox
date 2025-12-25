# View Claude Code Sandbox logs
# Requires PowerShell 5.1 or later

$ErrorActionPreference = "Stop"

Write-Host "Showing Claude Code Sandbox logs..." -ForegroundColor Cyan
Write-Host "Press Ctrl+C to exit" -ForegroundColor Yellow
Write-Host ""

# Show logs, follow if container is running
$runningContainer = docker ps --filter "name=claude-code-sandbox" --format "{{.Names}}"
if ($runningContainer -eq "claude-code-sandbox") {
    docker-compose logs -f
} else {
    docker-compose logs
}
