#!/bin/bash
# Claude Code Sandbox Rebuild Script
# Use this to rebuild the container after Dockerfile changes

set -e

echo "======================================"
echo "Claude Code Sandbox - Rebuild"
echo "======================================"
echo ""

# Check if container is running
if docker ps -q -f name=claude-code-sandbox > /dev/null 2>&1; then
    echo "Stopping running container..."
    docker-compose down
    echo ""
fi

echo "Rebuilding Docker container (no cache)..."
echo "This may take a few minutes..."
echo ""

docker-compose build --no-cache

echo ""
echo "[OK] Rebuild complete!"
echo ""
echo "Next steps:"
echo "  ./start.sh              # Start the container"
echo "  ./shell.sh              # Enter the container shell"
echo ""
