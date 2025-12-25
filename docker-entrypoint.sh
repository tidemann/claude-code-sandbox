#!/bin/bash
set -e

# Configure git credentials if GITHUB_PAT is provided
if [ -n "$GITHUB_PAT" ]; then
    echo "Configuring GitHub credentials..."

    # Set up git credential store with the PAT
    echo "https://${GITHUB_USERNAME:-git}:${GITHUB_PAT}@github.com" > /root/.git-credentials

    # Configure git user if provided
    if [ -n "$GIT_USER_NAME" ]; then
        git config --global user.name "$GIT_USER_NAME"
    fi

    if [ -n "$GIT_USER_EMAIL" ]; then
        git config --global user.email "$GIT_USER_EMAIL"
    fi

    echo "GitHub credentials configured successfully!"
else
    echo "Warning: GITHUB_PAT not set. GitHub operations may fail."
fi

# Configure Anthropic API key if provided
if [ -n "$ANTHROPIC_API_KEY" ]; then
    echo "Anthropic API key configured."
else
    echo "Warning: ANTHROPIC_API_KEY not set. Claude Code will not work without it."
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
