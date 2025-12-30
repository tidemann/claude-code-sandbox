#!/bin/bash
set -e

echo "======================================"
echo "Claude Code Sandbox Setup"
echo "======================================"
echo ""

# Check if .env exists
if [ -f .env ]; then
    echo "✓ .env file already exists"
    echo ""
    read -p "Do you want to reconfigure credentials? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Using existing .env file"
    else
        rm .env
    fi
fi

# Interactive setup if .env doesn't exist
if [ ! -f .env ]; then
    echo "Creating .env file..."
    echo ""

    # Prompt for Anthropic API Key
    echo "Enter your Anthropic API Key:"
    echo "(Get one at: https://console.anthropic.com/)"
    read -p "ANTHROPIC_API_KEY: " ANTHROPIC_API_KEY
    echo ""

    # Prompt for GitHub PAT
    echo "Enter your GitHub Personal Access Token:"
    echo "(Create one at: https://github.com/settings/tokens)"
    echo "Required scopes: 'repo' for private repos, 'public_repo' for public only"
    read -p "GITHUB_PAT: " GITHUB_PAT
    echo ""

    # Optional: GitHub username
    read -p "GitHub username (optional, press Enter to skip): " GITHUB_USERNAME
    echo ""

    # Optional: Git user name
    read -p "Git user name (optional, default: Claude Code Agent): " GIT_USER_NAME
    GIT_USER_NAME=${GIT_USER_NAME:-Claude Code Agent}
    echo ""

    # Optional: Git user email
    read -p "Git user email (optional, default: claude-code@example.com): " GIT_USER_EMAIL
    GIT_USER_EMAIL=${GIT_USER_EMAIL:-claude-code@example.com}
    echo ""

    # Optional: Repository URL for auto-clone
    echo "Auto-clone repository (optional):"
    echo "Enter a GitHub repository URL to automatically clone on container startup"
    read -p "Repository URL (optional, press Enter to skip): " REPO_URL
    echo ""

    # Write to .env file
    cat > .env << EOF
# Anthropic API Key (required for Claude Code)
ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}

# GitHub Personal Access Token (required for GitHub operations)
GITHUB_PAT=${GITHUB_PAT}

# GitHub username (optional, defaults to 'git')
GITHUB_USERNAME=${GITHUB_USERNAME}

# Git configuration (optional)
GIT_USER_NAME=${GIT_USER_NAME}
GIT_USER_EMAIL=${GIT_USER_EMAIL}

# Auto-clone repository (optional)
# If set, this repository will be automatically cloned to /workspace on container startup
REPO_URL=${REPO_URL}
EOF

    echo "✓ Created .env file with your credentials"
    echo ""
fi

# Validate required fields
if ! grep -q "ANTHROPIC_API_KEY=..*" .env; then
    echo "✗ Error: ANTHROPIC_API_KEY is not set in .env"
    exit 1
fi

if ! grep -q "GITHUB_PAT=..*" .env; then
    echo "✗ Error: GITHUB_PAT is not set in .env"
    exit 1
fi

echo "Building Docker container..."
docker compose build

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ Setup complete!"
    echo ""
    echo "Quick start:"
    echo "  ./start.sh              # Start the container"
    echo "  ./shell.sh              # Enter the container shell"
    echo "  ./stop.sh               # Stop the container"
    echo ""
    echo "Or use docker compose directly:"
    echo "  docker compose up -d    # Start in background"
    echo "  docker compose exec claude-code bash"
    echo ""
else
    echo ""
    echo "✗ Build failed. Please check the error messages above."
    exit 1
fi
