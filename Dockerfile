FROM node:20-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Claude Code CLI
RUN npm install -g @anthropic-ai/claude-code

# Create workspace directory
WORKDIR /workspace

# Set up git configuration placeholders (will be overridden by environment variables)
RUN git config --global user.name "Claude Code Agent" && \
    git config --global user.email "claude-code@example.com"

# Configure git to use credential helper for GitHub PAT
RUN git config --global credential.helper store

# Create a script to configure git credentials
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/bin/bash"]
