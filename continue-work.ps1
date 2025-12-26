# Continue Work - Autonomous Development Loop for Windows
# Launches Claude Code with /continue-work and monitors for activity
# Automatically restarts if Claude becomes idle

param(
    [int]$IdleTimeout = 900,  # Seconds of inactivity before restart (default: 15 minutes)
    [int]$MaxRestarts = 0     # Maximum restarts (0 = unlimited)
)

$ErrorActionPreference = "Stop"

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Continue Work - Autonomous Mode" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Idle timeout: $IdleTimeout seconds" -ForegroundColor Yellow
Write-Host "Max restarts: $(if ($MaxRestarts -eq 0) { 'Unlimited' } else { $MaxRestarts })" -ForegroundColor Yellow
Write-Host "Press Ctrl+C to stop" -ForegroundColor Yellow
Write-Host ""

# Load .env file to get REPO_URL
$envFile = ".env"
if (-not (Test-Path $envFile)) {
    Write-Host "[ERROR] .env file not found. Copy .env.example to .env first." -ForegroundColor Red
    exit 1
}

$repoUrl = Get-Content $envFile | Where-Object { $_ -match '^REPO_URL=' } | ForEach-Object { $_ -replace '^REPO_URL=', '' }

if (-not $repoUrl) {
    Write-Host "[ERROR] REPO_URL not set in .env file." -ForegroundColor Red
    exit 1
}

# Extract repo name from URL
$repoName = [System.IO.Path]::GetFileNameWithoutExtension($repoUrl)
$repoPath = "/workspace/$repoName"

# Check if container is running
$running = docker ps -q -f name=claude-code-sandbox 2>$null
if (-not $running) {
    Write-Host "Starting container..." -ForegroundColor Yellow
    docker-compose up -d
    Start-Sleep -Seconds 3
}

$restartCount = 0

while ($true) {
    $restartCount++

    if ($MaxRestarts -gt 0 -and $restartCount -gt $MaxRestarts) {
        Write-Host ""
        Write-Host "[INFO] Maximum restarts ($MaxRestarts) reached. Stopping." -ForegroundColor Yellow
        break
    }

    Write-Host "======================================" -ForegroundColor Green
    Write-Host "Starting iteration #$restartCount" -ForegroundColor Green
    Write-Host "======================================" -ForegroundColor Green
    Write-Host ""

    # Start Claude in background
    $claudeJob = Start-Job -ScriptBlock {
        param($repoPath, $containerName)
        # Keep stdin open with tail -f /dev/null
        docker exec -i -w $repoPath $containerName bash -c 'tail -f /dev/null | { DOCKER_GID=$(stat -c "%g" /var/run/docker.sock 2>/dev/null || echo ""); if [ -n "$DOCKER_GID" ] && [ "$DOCKER_GID" != "0" ]; then sg $DOCKER_GID -c "claude --dangerously-skip-permissions /continue-work"; else claude --dangerously-skip-permissions /continue-work; fi; }'
    } -ArgumentList $repoPath, "claude-code-sandbox"

    # Monitor activity
    $lastActivity = Get-Date
    $lastLogLineCount = 0
    $idleWarningShown = $false

    while ($claudeJob.State -eq "Running") {
        Start-Sleep -Seconds 5

        # Check container logs for new activity
        $currentLogs = docker logs --tail 50 claude-code-sandbox 2>&1
        $currentLogLineCount = ($currentLogs | Measure-Object -Line).Lines

        if ($currentLogLineCount -ne $lastLogLineCount) {
            $lastActivity = Get-Date
            $lastLogLineCount = $currentLogLineCount
            $idleWarningShown = $false
        }

        # Check idle time
        $idleSeconds = ((Get-Date) - $lastActivity).TotalSeconds

        if ($idleSeconds -gt $IdleTimeout) {
            Write-Host ""
            Write-Host "[TIMEOUT] No activity for $IdleTimeout seconds. Restarting..." -ForegroundColor Red
            Write-Host ""

            # Kill the job
            Stop-Job -Job $claudeJob
            Remove-Job -Job $claudeJob

            # Give container a moment to clean up
            Start-Sleep -Seconds 2
            break
        }
        elseif ($idleSeconds -gt ($IdleTimeout * 0.7) -and -not $idleWarningShown) {
            Write-Host "[WARNING] Idle for $([int]$idleSeconds) seconds (timeout: $IdleTimeout)" -ForegroundColor Yellow
            $idleWarningShown = $true
        }
    }

    # Check if job completed normally
    if ($claudeJob.State -eq "Completed") {
        Write-Host ""
        Write-Host "[INFO] Claude completed the task. Restarting..." -ForegroundColor Cyan
        Write-Host ""
        Remove-Job -Job $claudeJob
        Start-Sleep -Seconds 2
    }
    elseif ($claudeJob.State -eq "Failed") {
        Write-Host ""
        Write-Host "[ERROR] Claude failed. Restarting..." -ForegroundColor Red
        Write-Host ""
        Remove-Job -Job $claudeJob
        Start-Sleep -Seconds 5
    }
}

Write-Host ""
Write-Host "Autonomous mode stopped." -ForegroundColor Cyan
