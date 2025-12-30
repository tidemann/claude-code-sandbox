#!/bin/bash
set -e

echo "Starting Claude Code Sandbox..."

# Check if .env exists
if [ ! -f .env ]; then
    echo "✗ Error: .env file not found"
    echo "Please run ./setup.sh first to configure your credentials"
    exit 1
fi

# Check if container is already running
if docker ps | grep -q claude-code-sandbox; then
    echo "✓ Container is already running"
    echo ""
    echo "To access the shell, run:"
    echo "  ./shell.sh"
    exit 0
fi

# Start the container
docker compose up -d

# Wait for container to be ready
echo "Waiting for container to start..."
sleep 2

# Check if container started successfully
if docker ps | grep -q claude-code-sandbox; then
    echo "✓ Container started successfully!"
    echo ""
    echo "Container name: claude-code-sandbox"
    echo ""
    echo "Quick commands:"
    echo "  ./shell.sh              # Enter container shell"
    echo "  ./stop.sh               # Stop container"
    echo "  ./logs.sh               # View container logs"
    echo ""
    echo "Inside the container:"
    echo "  git clone https://github.com/username/repo.git"
    echo "  cd repo"
    echo "  claude-code"
else
    echo "✗ Failed to start container"
    echo "Check logs with: docker compose logs"
    exit 1
fi
