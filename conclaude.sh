#!/bin/bash
# ConClaude - Container Claude Quick Launch Script for Linux/Mac
# Launches Claude Code in yolo mode directly in the repo directory

set -e

# Load .env file to get REPO_URL
if [ ! -f .env ]; then
    echo "[ERROR] .env file not found. Copy .env.example to .env first."
    exit 1
fi

REPO_URL=$(grep '^REPO_URL=' .env | cut -d '=' -f2)

if [ -z "$REPO_URL" ]; then
    echo "[ERROR] REPO_URL not set in .env file."
    echo "Set REPO_URL in .env to auto-detect the repo directory."
    exit 1
fi

# Extract repo name from URL
REPO_NAME=$(basename "$REPO_URL" .git)
REPO_PATH="/workspace/$REPO_NAME"

# Check if container is running
if ! docker ps -q -f name=claude-code-sandbox > /dev/null 2>&1; then
    echo "Starting container..."
    docker-compose up -d
    sleep 2
fi

# Build the claude command
TASK="$*"

if [ -n "$TASK" ]; then
    echo "Launching Claude Code in $REPO_PATH with task: $TASK"
    docker exec -it -w "$REPO_PATH" claude-code-sandbox bash -c 'DOCKER_GID=$(stat -c "%g" /var/run/docker.sock 2>/dev/null || echo ""); if [ -n "$DOCKER_GID" ] && [ "$DOCKER_GID" != "0" ]; then sg $DOCKER_GID -c "claude --dangerously-skip-permissions '"$TASK"'"; else claude --dangerously-skip-permissions "'"$TASK"'"; fi'
else
    echo "Launching Claude Code in interactive mode at $REPO_PATH"
    docker exec -it -w "$REPO_PATH" claude-code-sandbox bash -c 'DOCKER_GID=$(stat -c "%g" /var/run/docker.sock 2>/dev/null || echo ""); if [ -n "$DOCKER_GID" ] && [ "$DOCKER_GID" != "0" ]; then sg $DOCKER_GID -c "claude --dangerously-skip-permissions"; else claude --dangerously-skip-permissions; fi'
fi
