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

# Enter the container
docker-compose exec claude-code bash
