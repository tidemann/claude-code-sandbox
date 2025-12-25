# Claude Code Sandbox Setup Script for Windows
# Requires PowerShell 5.1 or later

$ErrorActionPreference = "Stop"

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Claude Code Sandbox Setup" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Check if .env exists
if (Test-Path .env) {
    Write-Host "[OK] .env file already exists" -ForegroundColor Green
    Write-Host ""
    $reconfigure = Read-Host "Do you want to reconfigure credentials? (y/N)"

    if ($reconfigure -notmatch "^[Yy]$") {
        Write-Host "Using existing .env file" -ForegroundColor Yellow
    } else {
        Remove-Item .env
    }
}

# Interactive setup if .env doesn't exist
if (-not (Test-Path .env)) {
    Write-Host "Creating .env file..." -ForegroundColor Cyan
    Write-Host ""

    # Prompt for Anthropic API Key
    Write-Host "Enter your Anthropic API Key:"
    Write-Host "(Get one at: https://console.anthropic.com/)" -ForegroundColor Gray
    $ANTHROPIC_API_KEY = Read-Host "ANTHROPIC_API_KEY"
    Write-Host ""

    # Prompt for GitHub PAT
    Write-Host "Enter your GitHub Personal Access Token:"
    Write-Host "(Create one at: https://github.com/settings/tokens)" -ForegroundColor Gray
    Write-Host "Required scopes: 'repo' for private repos, 'public_repo' for public only" -ForegroundColor Gray
    $GITHUB_PAT = Read-Host "GITHUB_PAT"
    Write-Host ""

    # Optional: GitHub username
    Write-Host "GitHub username (optional - press Enter to skip):" -ForegroundColor Gray
    $GITHUB_USERNAME = Read-Host
    Write-Host ""

    # Optional: Git user name
    Write-Host "Git user name (optional - default: Claude Code Agent):" -ForegroundColor Gray
    $GIT_USER_NAME = Read-Host
    if ([string]::IsNullOrWhiteSpace($GIT_USER_NAME)) {
        $GIT_USER_NAME = "Claude Code Agent"
    }
    Write-Host ""

    # Optional: Git user email
    Write-Host "Git user email (optional - default: claude-code@example.com):" -ForegroundColor Gray
    $GIT_USER_EMAIL = Read-Host
    if ([string]::IsNullOrWhiteSpace($GIT_USER_EMAIL)) {
        $GIT_USER_EMAIL = "claude-code@example.com"
    }
    Write-Host ""

    # Optional: Repository URL for auto-clone
    Write-Host "Auto-clone repository (optional):" -ForegroundColor Gray
    Write-Host "Enter a GitHub repository URL to automatically clone on container startup" -ForegroundColor Gray
    Write-Host "Repository URL (press Enter to skip):" -ForegroundColor Gray
    $REPO_URL = Read-Host
    Write-Host ""

    # Write to .env file
    $envContent = @"
# Anthropic API Key (required for Claude Code)
ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY

# GitHub Personal Access Token (required for GitHub operations)
GITHUB_PAT=$GITHUB_PAT

# GitHub username (optional, defaults to 'git')
GITHUB_USERNAME=$GITHUB_USERNAME

# Git configuration (optional)
GIT_USER_NAME=$GIT_USER_NAME
GIT_USER_EMAIL=$GIT_USER_EMAIL

# Auto-clone repository (optional)
# If set, this repository will be automatically cloned to /workspace on container startup
REPO_URL=$REPO_URL
"@

    $envContent | Out-File -FilePath .env -Encoding UTF8 -NoNewline
    Write-Host "[OK] Created .env file with your credentials" -ForegroundColor Green
    Write-Host ""
}

# Validate required fields
$envFileContent = Get-Content .env -Raw
if ($envFileContent -notmatch "ANTHROPIC_API_KEY=.+") {
    Write-Host "[ERROR] ANTHROPIC_API_KEY is not set in .env" -ForegroundColor Red
    exit 1
}

if ($envFileContent -notmatch "GITHUB_PAT=.+") {
    Write-Host "[ERROR] GITHUB_PAT is not set in .env" -ForegroundColor Red
    exit 1
}

Write-Host "Building Docker container..." -ForegroundColor Cyan
docker-compose build

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "[OK] Setup complete!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Quick start:" -ForegroundColor Cyan
    Write-Host "  .\start.ps1              # Start the container"
    Write-Host "  .\shell.ps1              # Enter the container shell"
    Write-Host "  .\stop.ps1               # Stop the container"
    Write-Host ""
    Write-Host "Or use docker-compose directly:" -ForegroundColor Cyan
    Write-Host "  docker-compose up -d    # Start in background"
    Write-Host "  docker-compose exec claude-code bash"
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "[ERROR] Build failed. Please check the error messages above." -ForegroundColor Red
    exit 1
}
