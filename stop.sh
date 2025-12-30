#!/bin/bash
set -e

echo "Stopping Claude Code Sandbox..."

# Check if container is running
if ! docker ps | grep -q claude-code-sandbox; then
    echo "✓ Container is not running"
    exit 0
fi

# Stop the container
docker compose down

echo "✓ Container stopped successfully"
echo ""
echo "To start again, run:"
echo "  ./start.sh"
