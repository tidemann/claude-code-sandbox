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

# Execute the main command
exec "$@"
