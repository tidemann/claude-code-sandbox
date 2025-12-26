#!/bin/bash
set -e

echo "================================================"
echo "Claude Code Sandbox Container"
echo "================================================"
echo ""

# Fix permissions for claude credentials directory
# This is needed because Docker volume mounts may have incorrect permissions
if [ -d "$HOME/.claude" ]; then
    # Ensure the directory and all subdirectories are owned by the current user
    sudo chown -R $(id -u):$(id -g) "$HOME/.claude" 2>/dev/null || true
    chmod -R u+rwX "$HOME/.claude" 2>/dev/null || true
    echo "✓ Claude credentials directory mounted and permissions fixed"
else
    echo "⚠ Warning: Claude credentials directory not found, creating..."
    mkdir -p "$HOME/.claude"
    chmod 700 "$HOME/.claude"
fi

# Fix Docker socket permissions for Docker-in-Docker support
if [ -e /var/run/docker.sock ]; then
    echo "Configuring Docker socket access..."

    # Get the GID of the docker socket on the host
    DOCKER_SOCK_GID=$(stat -c '%g' /var/run/docker.sock)

    # Check if a group with this GID already exists
    if ! getent group $DOCKER_SOCK_GID > /dev/null 2>&1; then
        # Create a new group with the same GID as the docker socket
        sudo groupadd -g $DOCKER_SOCK_GID docker-host
    fi

    # Add the current user to the group with the socket's GID
    sudo usermod -aG $DOCKER_SOCK_GID $(whoami)

    echo "✓ Docker socket access configured (GID: $DOCKER_SOCK_GID)"
    echo "  Note: You may need to run 'newgrp $DOCKER_SOCK_GID' or restart your shell"
else
    echo "⚠ Warning: Docker socket not found at /var/run/docker.sock"
    echo "  Docker commands will not work inside this container."
fi
echo ""

# Verify Claude Code is installed
if command -v claude &> /dev/null; then
    CLAUDE_VERSION=$(claude --version 2>&1 || echo "unknown")
    echo "✓ Claude Code installed: $CLAUDE_VERSION"
    echo "  (Available as both 'claude' and 'claude-code' commands)"
else
    echo "✗ ERROR: Claude not found in PATH"
    echo "  This shouldn't happen. Please rebuild the container."
    exit 1
fi
echo ""

# Configure git credentials if GITHUB_PAT is provided
if [ -n "$GITHUB_PAT" ]; then
    echo "Configuring GitHub credentials..."

    # Set up git credential store with the PAT
    echo "https://${GITHUB_USERNAME:-git}:${GITHUB_PAT}@github.com" > ~/.git-credentials

    # Export GITHUB_PAT as GH_TOKEN for GitHub CLI
    export GH_TOKEN="$GITHUB_PAT"
    echo "✓ GitHub CLI (gh) token configured"

    # Configure git user if provided
    if [ -n "$GIT_USER_NAME" ]; then
        git config --global user.name "$GIT_USER_NAME"
    fi

    if [ -n "$GIT_USER_EMAIL" ]; then
        git config --global user.email "$GIT_USER_EMAIL"
    fi

    echo "✓ GitHub credentials configured successfully!"
else
    echo "Warning: GITHUB_PAT not set. GitHub operations may fail."
fi

# Configure Claude Code authentication
CLAUDE_AUTH_MODE=${CLAUDE_AUTH_MODE:-api-key}

if [ "$CLAUDE_AUTH_MODE" = "max-plan" ]; then
    echo "================================================"
    echo "Claude Code Authentication: Subscription Mode"
    echo "================================================"
    echo ""
    echo "You're using claude.ai subscription authentication."
    echo ""

    # Check if already authenticated
    if [ -f "$HOME/.claude/.credentials.json" ] || [ -f "$HOME/.claude/credentials" ] || [ -f "$HOME/.claude/config.json" ]; then
        echo "✓ Authentication found - you're already logged in!"
        echo ""
    else
        echo "⚠ Not authenticated yet."
        echo ""
        echo "To authenticate Claude Code with your subscription:"
        echo "  1. Run: claude login"
        echo "  2. Follow the prompts to log in with your claude.ai account"
        echo "  3. Choose the option that matches your subscription type"
        echo ""
        echo "Your credentials will be persisted in ./claude-credentials/ on the host"
        echo "and will be available on future container restarts."
        echo ""
    fi

    echo "Quick start:"
    echo "  claude                                      # Interactive mode"
    echo "  claude \"your task\"                         # One-off task"
    echo "  claude --dangerously-skip-permissions       # Yolo mode (skip permission prompts)"
    echo "================================================"
    echo ""
elif [ "$CLAUDE_AUTH_MODE" = "api-key" ]; then
    if [ -n "$ANTHROPIC_API_KEY" ]; then
        echo "Claude Code Authentication: API Key Mode"
        echo "Anthropic API key configured."
    else
        echo "Warning: ANTHROPIC_API_KEY not set. Claude Code will not work without it."
    fi
else
    echo "Warning: Unknown CLAUDE_AUTH_MODE='$CLAUDE_AUTH_MODE'. Expected 'api-key' or 'max-plan'."
fi

# Auto-clone repository if REPO_URL is provided
if [ -n "$REPO_URL" ]; then
    echo "Auto-clone enabled for: $REPO_URL"

    # Extract repository name from URL (e.g., https://github.com/user/repo.git -> repo)
    REPO_NAME=$(basename "$REPO_URL" .git)
    REPO_PATH="/workspace/$REPO_NAME"

    if [ -d "$REPO_PATH" ]; then
        echo "Repository '$REPO_NAME' already exists at $REPO_PATH"

        # Optionally pull latest changes
        if [ "$AUTO_PULL" = "true" ]; then
            echo "Pulling latest changes..."
            cd "$REPO_PATH"
            git pull || echo "Warning: Failed to pull latest changes"
            cd /workspace
        fi
    else
        echo "Cloning repository to $REPO_PATH..."
        if git clone "$REPO_URL" "$REPO_PATH"; then
            echo "✓ Repository cloned successfully!"
            echo "Navigate to it with: cd $REPO_PATH"
        else
            echo "✗ Failed to clone repository. Check your REPO_URL and credentials."
        fi
    fi
else
    echo "No REPO_URL configured. Clone repositories manually with 'git clone'."
fi

# Execute the main command
exec "$@"
