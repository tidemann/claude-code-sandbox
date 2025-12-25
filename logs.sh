#!/bin/bash
set -e

echo "Showing Claude Code Sandbox logs..."
echo "Press Ctrl+C to exit"
echo ""

# Show logs, follow if container is running
if docker ps | grep -q claude-code-sandbox; then
    docker-compose logs -f
else
    docker-compose logs
fi
