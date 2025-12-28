FROM node:20-slim

# Install system dependencies, GitHub CLI, and Docker
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    bash \
    sudo \
    gnupg \
    lsb-release \
    procps \
    && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list \
    && apt-get update \
    && apt-get install -y gh docker-ce-cli docker-compose-plugin \
    && rm -rf /var/lib/apt/lists/*

# Use the existing node user for Claude Code
# The node:20-slim image already has a 'node' user with UID 1000
# This is required for --dangerously-skip-permissions flag to work
RUN echo "node ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && groupadd -f docker \
    && usermod -aG docker node

# Switch to node user for Claude Code installation
USER node
WORKDIR /home/node

# Install Claude Code CLI using official installer
# The installer adds claude to ~/.local/bin
RUN curl -fsSL https://claude.ai/install.sh | bash

# Add claude installation directory to PATH
ENV PATH="/home/node/.local/bin:${PATH}"

# Switch back to root to create symlinks and set up workspace
USER root

# Create symlink for both 'claude' and 'claude-code' commands
RUN ln -s /home/node/.local/bin/claude /usr/local/bin/claude && \
    ln -s /home/node/.local/bin/claude /usr/local/bin/claude-code

# Verify installation
RUN which claude && which claude-code

# Create workspace directory and set ownership
RUN mkdir -p /workspace && chown -R node:node /workspace

# Set up git configuration for node user
USER node
RUN git config --global user.name "Claude Code Agent" && \
    git config --global user.email "claude-code@example.com" && \
    git config --global credential.helper store

# Copy entrypoint script and make it executable
USER root
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Switch to node user for runtime
USER node
WORKDIR /workspace

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/bin/bash"]
