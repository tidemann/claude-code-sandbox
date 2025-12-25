# Claude Code Sandbox Container

A Docker container setup for running Claude Code agents in a sandboxed environment with GitHub access via Personal Access Token (PAT).

## Prerequisites

- Docker and Docker Compose installed
- Anthropic API key ([get one here](https://console.anthropic.com/))
- GitHub Personal Access Token ([create one here](https://github.com/settings/tokens))

## Setup

1. **Copy the environment template:**
   ```bash
   cp .env.example .env
   ```

2. **Edit `.env` file and add your credentials:**
   - `ANTHROPIC_API_KEY`: Your Anthropic API key
   - `GITHUB_PAT`: Your GitHub Personal Access Token
     - For private repos, use token with `repo` scope
     - For public repos only, use token with `public_repo` scope
   - `GITHUB_USERNAME`: Your GitHub username (optional)
   - `GIT_USER_NAME`: Your name for git commits (optional)
   - `GIT_USER_EMAIL`: Your email for git commits (optional)

3. **Build the container:**
   ```bash
   docker-compose build
   ```

## Usage

### Start the container

```bash
docker-compose up -d
```

### Enter the container

```bash
docker-compose exec claude-code bash
```

Or attach to the running container:

```bash
docker attach claude-code-sandbox
```

### Clone a repository inside the container

Once inside the container:

```bash
git clone https://github.com/your-username/your-repo.git
cd your-repo
```

### Run Claude Code

```bash
claude-code
```

Or run a specific command:

```bash
claude-code "fix the bug in src/main.js"
```

### Stop the container

```bash
docker-compose down
```

## Directory Structure

```
.
├── Dockerfile              # Container definition
├── docker-compose.yml      # Docker Compose configuration
├── docker-entrypoint.sh    # Startup script for credential setup
├── .env                    # Your credentials (gitignored)
├── .env.example            # Template for credentials
├── workspace/              # Persistent workspace (created on first run)
└── README.md              # This file
```

## Security Notes

- The `.env` file contains sensitive credentials. **Never commit it to version control.**
- The container has full access to GitHub using your PAT, so use it responsibly.
- Consider using a PAT with minimal required scopes.
- The workspace directory persists between container restarts.

## Troubleshooting

### GitHub authentication fails

- Verify your `GITHUB_PAT` in `.env` is correct
- Check the PAT has the required scopes
- Ensure the PAT hasn't expired

### Claude Code doesn't work

- Verify your `ANTHROPIC_API_KEY` in `.env` is correct
- Check you have API credits available

### Permission errors

- The container runs as root by default
- Files created in the workspace will be owned by root

## Advanced Usage

### Mount a specific repository

Edit `docker-compose.yml` and add a volume mount:

```yaml
volumes:
  - ./workspace:/workspace
  - /path/to/your/local/repo:/workspace/repo
```

### Use with CI/CD

You can use this container in CI/CD pipelines by passing environment variables:

```bash
docker run -e ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY \
           -e GITHUB_PAT=$GITHUB_PAT \
           -v $(pwd):/workspace \
           claude-code-sandbox \
           bash -c "git clone https://github.com/user/repo && cd repo && claude-code 'your task here'"
```

## Cleanup

To remove the container and images:

```bash
docker-compose down
docker rmi claude-code-sandbox
```

To also remove the workspace:

```bash
rm -rf workspace/
```
