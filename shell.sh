#!/bin/bash
set -e

# Check if container is running
if ! docker ps | grep -q claude-code-sandbox; then
    echo "✗ Error: Container is not running"
    echo ""
    echo "Start the container first:"
    echo "  ./start.sh"
    exit 1
fi

echo "Entering Claude Code Sandbox shell..."
echo "Type 'exit' to leave the container"
echo ""

# Enter the container with docker group access
docker-compose exec claude-code bash -c 'DOCKER_GID=$(stat -c "%g" /var/run/docker.sock 2>/dev/null || echo ""); if [ -n "$DOCKER_GID" ]; then exec sg $DOCKER_GID bash; else exec bash; fi'
