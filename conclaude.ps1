# ConClaude - Container Claude Quick Launch Script for Windows
# Launches Claude Code in yolo mode directly in the repo directory

param(
    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$TaskArgs
)

$ErrorActionPreference = "Stop"

# Load .env file to get REPO_URL
$envFile = ".env"
if (-not (Test-Path $envFile)) {
    Write-Host "[ERROR] .env file not found. Copy .env.example to .env first." -ForegroundColor Red
    exit 1
}

$repoUrl = Get-Content $envFile | Where-Object { $_ -match '^REPO_URL=' } | ForEach-Object { $_ -replace '^REPO_URL=', '' }

if (-not $repoUrl) {
    Write-Host "[ERROR] REPO_URL not set in .env file." -ForegroundColor Red
    Write-Host "Set REPO_URL in .env to auto-detect the repo directory." -ForegroundColor Yellow
    exit 1
}

# Extract repo name from URL
$repoName = [System.IO.Path]::GetFileNameWithoutExtension($repoUrl)
$repoPath = "/workspace/$repoName"

# Check if container is running
$running = docker ps -q -f name=claude-code-sandbox 2>$null

if (-not $running) {
    # Remove any stopped/stale container first
    $exists = docker ps -aq -f name=claude-code-sandbox 2>$null
    if ($exists) {
        Write-Host "Removing stale container..." -ForegroundColor Yellow
        docker rm -f claude-code-sandbox 2>$null
    }
    Write-Host "Starting container..." -ForegroundColor Yellow
    docker-compose up -d
    Start-Sleep -Seconds 2
}

# Build the claude command
$task = if ($TaskArgs) { $TaskArgs -join " " } else { "" }

if ($task) {
    Write-Host "Launching Claude Code in $repoPath with task: $task" -ForegroundColor Cyan
    docker exec -it -w $repoPath claude-code-sandbox bash -c "DOCKER_GID=`$(stat -c '%g' /var/run/docker.sock 2>/dev/null || echo ''); if [ -n `"`$DOCKER_GID`" ] && [ `"`$DOCKER_GID`" != '0' ]; then sg `$DOCKER_GID -c 'claude --dangerously-skip-permissions $task'; else claude --dangerously-skip-permissions $task; fi"
} else {
    Write-Host "Launching Claude Code in interactive mode at $repoPath" -ForegroundColor Cyan
    docker exec -it -w $repoPath claude-code-sandbox bash -c "DOCKER_GID=`$(stat -c '%g' /var/run/docker.sock 2>/dev/null || echo ''); if [ -n `"`$DOCKER_GID`" ] && [ `"`$DOCKER_GID`" != '0' ]; then sg `$DOCKER_GID -c 'claude --dangerously-skip-permissions'; else claude --dangerously-skip-permissions; fi"
}
