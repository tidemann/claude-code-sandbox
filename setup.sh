#!/bin/bash

echo "======================================"
echo "Claude Code Sandbox Setup"
echo "======================================"
echo ""

# Check if .env exists
if [ -f .env ]; then
    echo "✓ .env file already exists"
else
    echo "Creating .env file from template..."
    cp .env.example .env
    echo "✓ Created .env file"
    echo ""
    echo "⚠️  IMPORTANT: Edit .env and add your credentials:"
    echo "   - ANTHROPIC_API_KEY"
    echo "   - GITHUB_PAT"
    echo ""
    read -p "Press Enter to continue after editing .env..."
fi

echo ""
echo "Building Docker container..."
docker-compose build

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ Setup complete!"
    echo ""
    echo "Next steps:"
    echo "  1. Start the container: docker-compose up -d"
    echo "  2. Enter the container: docker-compose exec claude-code bash"
    echo "  3. Clone your repo: git clone https://github.com/username/repo.git"
    echo "  4. Run Claude Code: claude-code"
    echo ""
else
    echo ""
    echo "✗ Build failed. Please check the error messages above."
    exit 1
fi
