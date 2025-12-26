# Claude Code Sandbox Container

A Docker container setup for running Claude Code agents in a sandboxed environment with GitHub access via Personal Access Token (PAT).

## Prerequisites

- Docker and Docker Compose installed
- **Either:**
  - Claude.ai subscription (Pro or higher, [subscribe here](https://claude.ai/)) **OR**
  - Anthropic API key ([get one here](https://console.anthropic.com/))
- GitHub Personal Access Token ([create one here](https://github.com/settings/tokens))

## Authentication Modes

This container supports two authentication modes:

### 1. Subscription Mode (Recommended for claude.ai subscribers)
- Use your existing claude.ai subscription (Pro or higher)
- Authenticate inside the container with `claude login`
- No additional API costs
- Credentials persist across container restarts

### 2. API Key Mode (For API users)
- Use an Anthropic API key from console.anthropic.com
- Pay-as-you-go pricing
- Automatic authentication via environment variable

## Quick Start

### Linux/macOS

**Interactive setup (recommended):**
```bash
./setup.sh
```

The setup script will:
- Ask which authentication mode you want to use (Subscription or API Key)
- Prompt you for your Anthropic API key (if using API Key mode)
- Prompt you for your GitHub Personal Access Token
- Create a `.env` file with your credentials
- Build the Docker container

**Then use the helper scripts:**
```bash
./start.sh         # Start the container
./shell.sh         # Enter the container shell
./conclaude.sh     # Quick launch Claude in yolo mode (auto-start container)
./continue-work.sh # Autonomous mode - runs /continue-work with activity monitoring
./stop.sh          # Stop the container
./logs.sh          # View container logs
./rebuild.sh       # Rebuild after changes
```

### Windows (PowerShell)

**Interactive setup (recommended):**
```powershell
.\setup.ps1
```

The setup script will:
- Ask which authentication mode you want to use (Subscription or API Key)
- Prompt you for your Anthropic API key (if using API Key mode)
- Prompt you for your GitHub Personal Access Token
- Create a `.env` file with your credentials
- Build the Docker container

**Then use the helper scripts:**
```powershell
.\start.ps1         # Start the container
.\shell.ps1         # Enter the container shell
.\conclaude.ps1     # Quick launch Claude in yolo mode (auto-start container)
.\continue-work.ps1 # Autonomous mode - runs /continue-work with activity monitoring
.\stop.ps1          # Stop the container
.\logs.ps1          # View container logs
.\rebuild.ps1       # Rebuild after changes
```

## Manual Setup

If you prefer manual setup:

1. **Copy the environment template:**
   ```bash
   cp .env.example .env
   ```

2. **Edit `.env` file and add your credentials:**
   - `CLAUDE_AUTH_MODE`: Authentication mode (`api-key` or `max-plan`)
   - `ANTHROPIC_API_KEY`: Your Anthropic API key (required only if using `api-key` mode)
   - `GITHUB_PAT`: Your GitHub Personal Access Token
     - For private repos, use token with `repo` scope
     - For public repos only, use token with `public_repo` scope
   - `GITHUB_USERNAME`: Your GitHub username (optional)
   - `GIT_USER_NAME`: Your name for git commits (optional)
   - `GIT_USER_EMAIL`: Your email for git commits (optional)
   - `REPO_URL`: GitHub repository URL to auto-clone on startup (optional)

3. **Build the container:**
   ```bash
   docker-compose build
   ```

## Usage

### Quick Commands (Helper Scripts)

**Linux/macOS:**
```bash
./start.sh    # Start the container in background
./shell.sh    # Enter the container shell
./stop.sh     # Stop the container
./logs.sh     # View container logs
```

**Windows (PowerShell):**
```powershell
.\start.ps1    # Start the container in background
.\shell.ps1    # Enter the container shell
.\stop.ps1     # Stop the container
.\logs.ps1     # View container logs
```

### Manual Commands

Start the container:
```bash
docker-compose up -d
```

Enter the container:
```bash
docker-compose exec claude-code bash
```

Stop the container:
```bash
docker-compose down
```

### Inside the Container

**If using Subscription mode**, authenticate first:
```bash
claude login
# Follow the prompts to log in with your claude.ai account
# Choose the option for your subscription type
```

Clone a repository:
```bash
git clone https://github.com/your-username/your-repo.git
cd your-repo
```

Run Claude Code:
```bash
claude                                    # Interactive mode
claude "fix the bug in main.js"           # One-off task
claude --dangerously-skip-permissions     # Yolo mode (skip permission prompts)
```

## Yolo Mode (Skip Permission Prompts)

Claude Code normally prompts for permission before executing commands. In a sandboxed container environment, you may want to skip these prompts for faster iteration.

**Enable yolo mode:**
```bash
claude --dangerously-skip-permissions
```

This works because the container runs as a non-root user (`node`). The `--dangerously-skip-permissions` flag is blocked when running as root for security reasons.

**Note:** Only use this in trusted, sandboxed environments like this Docker container.

## Autonomous Development Mode

The `continue-work` scripts enable fully autonomous development loops where Claude continuously works on tasks with automatic restart on idle.

**Windows:**
```powershell
.\continue-work.ps1                    # Start autonomous mode with defaults
.\continue-work.ps1 -IdleTimeout 1800  # Custom 30-minute idle timeout
.\continue-work.ps1 -MaxRestarts 10    # Stop after 10 restarts
```

**Linux/Mac:**
```bash
./continue-work.sh                     # Start autonomous mode with defaults
IDLE_TIMEOUT=1800 ./continue-work.sh   # Custom 30-minute idle timeout
MAX_RESTARTS=10 ./continue-work.sh     # Stop after 10 restarts
```

**How it works:**
1. Launches Claude with `/continue-work` command in yolo mode
2. Monitors container logs for activity every 5 seconds
3. If no new log output for 15 minutes (default), automatically restarts
4. Loops indefinitely until manually stopped with Ctrl+C

**Use cases:**
- Autonomous bug fixing and task completion
- Overnight development sessions
- Continuous integration/improvement workflows
- Long-running refactoring tasks

**Example workflow:**
```powershell
# Set up your repo and issues in GitHub first
.\continue-work.ps1

# Claude will:
# - Query GitHub for issues
# - Pick tasks to work on
# - Implement, test, and commit changes
# - Create pull requests
# - Restart automatically if idle
# - Loop until you stop it
```

## ConClaude - Quick Launch Scripts

The `conclaude` scripts provide a one-command way to launch Claude Code in yolo mode directly in your repository directory.

**Linux/macOS:**
```bash
./conclaude.sh                    # Interactive mode in repo directory
./conclaude.sh "your task here"   # One-off task
```

**Windows:**
```powershell
.\conclaude.ps1                    # Interactive mode in repo directory
.\conclaude.ps1 "your task here"   # One-off task
```

**Features:**
- Auto-starts the container if not running
- Auto-navigates to your repository (from `REPO_URL` in `.env`)
- Launches Claude in yolo mode (`--dangerously-skip-permissions`)
- No confusion with local `claude` installation

**Example:**
```bash
# Set REPO_URL in .env first
./conclaude.sh "implement feature X"
```

## Auto-Clone Feature

You can configure a repository to be automatically cloned when the container starts by setting `REPO_URL` in your `.env` file:

```bash
REPO_URL=https://github.com/username/repo.git
```

**How it works:**
- On container startup, if `REPO_URL` is set, the repo will be automatically cloned to `/workspace/<repo-name>`
- If the repo already exists, it will be skipped (no re-cloning)
- The repository will be ready to use immediately when you enter the shell

**Example workflow (Linux/macOS):**
```bash
# In .env
REPO_URL=https://github.com/username/my-project.git

# Start container
./start.sh

# Enter shell - repo is already cloned!
./shell.sh

# Inside container
cd my-project
claude-code "implement feature X"
```

**Example workflow (Windows):**
```powershell
# In .env
REPO_URL=https://github.com/username/my-project.git

# Start container
.\start.ps1

# Enter shell - repo is already cloned!
.\shell.ps1

# Inside container
cd my-project
claude-code "implement feature X"
```

## Directory Structure

```
.
├── Dockerfile              # Container definition
├── docker-compose.yml      # Docker Compose configuration
├── docker-entrypoint.sh    # Startup script for credential setup
├── setup.sh                # Interactive setup script (Linux/macOS)
├── setup.ps1               # Interactive setup script (Windows)
├── start.sh                # Start container helper (Linux/macOS)
├── start.ps1               # Start container helper (Windows)
├── stop.sh                 # Stop container helper (Linux/macOS)
├── stop.ps1                # Stop container helper (Windows)
├── shell.sh                # Enter container shell helper (Linux/macOS)
├── shell.ps1               # Enter container shell helper (Windows)
├── logs.sh                 # View logs helper (Linux/macOS)
├── logs.ps1                # View logs helper (Windows)
├── rebuild.sh              # Rebuild container helper (Linux/macOS)
├── rebuild.ps1             # Rebuild container helper (Windows)
├── conclaude.sh            # Quick launch Claude in yolo mode (Linux/macOS)
├── conclaude.ps1           # Quick launch Claude in yolo mode (Windows)
├── continue-work.sh        # Autonomous mode with activity monitoring (Linux/macOS)
├── continue-work.ps1       # Autonomous mode with activity monitoring (Windows)
├── .env                    # Your credentials (gitignored)
├── .env.example            # Template for credentials
├── workspace/              # Persistent workspace (created on first run)
├── claude-credentials/     # Claude Code auth tokens (gitignored, created on first login)
├── LICENSE                 # MIT License
├── CONTRIBUTING.md         # Contributing guidelines
└── README.md              # This file
```

## Security Notes

- The `.env` file contains sensitive credentials. **Never commit it to version control.**
- The container has full access to GitHub using your PAT, so use it responsibly.
- Consider using a PAT with minimal required scopes.
- The workspace directory persists between container restarts.

## Docker-in-Docker Support

The container includes Docker CLI and has access to the host Docker daemon via socket mounting. This allows Claude Code to:
- Run Docker commands from inside the container
- Build and run containers
- Use docker-compose

**Example use cases:**
- Testing Dockerized applications
- Building and pushing container images
- Running integration tests with Docker

**Note:** The container shares the host's Docker daemon, so containers started inside are actually running on the host.

## Troubleshooting

### GitHub authentication fails

- Verify your `GITHUB_PAT` in `.env` is correct
- Check the PAT has the required scopes (at minimum: `repo` for private repos or `public_repo` for public only)
- Ensure the PAT hasn't expired
- Test with `gh auth status` inside the container

### Claude Code doesn't work

**API Key Mode:**
- Verify your `ANTHROPIC_API_KEY` in `.env` is correct
- Check you have API credits available at console.anthropic.com

**Subscription Mode:**
- Run `claude login` inside the container
- Your credentials will be saved to `./claude-credentials/` on the host
- Credentials persist across container restarts
- If you're asked to re-authenticate every time:
  - Check that `./claude-credentials/` directory exists on the host
  - Verify the volume mount in docker-compose.yml: `./claude-credentials:/home/node/.claude`
  - Check permissions: the directory should be readable/writable

### Permission errors

- The container runs as the `node` user (UID 1000) by default
- Files created in the workspace will be owned by UID 1000
- Use `sudo` inside the container if you need root access

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
