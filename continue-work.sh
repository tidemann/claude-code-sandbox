#!/bin/bash
# Continue Work - Autonomous Development Loop for Linux/Mac
# Launches Claude Code with /continue-work and monitors for activity
# Automatically restarts if Claude becomes idle

set -e

# Configuration
IDLE_TIMEOUT=${IDLE_TIMEOUT:-900}  # Seconds of inactivity before restart (default: 15 minutes)
MAX_RESTARTS=${MAX_RESTARTS:-0}    # Maximum restarts (0 = unlimited)

echo "======================================"
echo "Continue Work - Autonomous Mode"
echo "======================================"
echo ""
echo "Idle timeout: $IDLE_TIMEOUT seconds"
echo "Max restarts: $([ $MAX_RESTARTS -eq 0 ] && echo 'Unlimited' || echo $MAX_RESTARTS)"
echo "Press Ctrl+C to stop"
echo ""

# Load .env file to get REPO_URL
if [ ! -f .env ]; then
    echo "[ERROR] .env file not found. Copy .env.example to .env first."
    exit 1
fi

REPO_URL=$(grep '^REPO_URL=' .env | cut -d '=' -f2)

if [ -z "$REPO_URL" ]; then
    echo "[ERROR] REPO_URL not set in .env file."
    exit 1
fi

# Extract repo name from URL
REPO_NAME=$(basename "$REPO_URL" .git)
REPO_PATH="/workspace/$REPO_NAME"

# Check if container is running
if ! docker ps -q -f name=claude-code-sandbox > /dev/null 2>&1; then
    echo "Starting container..."
    docker-compose up -d
    sleep 3
fi

RESTART_COUNT=0

# Cleanup function
cleanup() {
    echo ""
    echo "Cleaning up..."
    if [ -n "$CLAUDE_PID" ] && ps -p $CLAUDE_PID > /dev/null 2>&1; then
        kill $CLAUDE_PID 2>/dev/null || true
    fi
    echo "Autonomous mode stopped."
    exit 0
}

trap cleanup SIGINT SIGTERM

while true; do
    RESTART_COUNT=$((RESTART_COUNT + 1))

    if [ $MAX_RESTARTS -gt 0 ] && [ $RESTART_COUNT -gt $MAX_RESTARTS ]; then
        echo ""
        echo "[INFO] Maximum restarts ($MAX_RESTARTS) reached. Stopping."
        break
    fi

    echo "======================================"
    echo "Starting iteration #$RESTART_COUNT"
    echo "======================================"
    echo ""

    # Start Claude in background
    docker exec -i -w "$REPO_PATH" claude-code-sandbox bash -c 'DOCKER_GID=$(stat -c "%g" /var/run/docker.sock 2>/dev/null || echo ""); if [ -n "$DOCKER_GID" ] && [ "$DOCKER_GID" != "0" ]; then sg $DOCKER_GID -c "claude --dangerously-skip-permissions /continue-work"; else claude --dangerously-skip-permissions /continue-work; fi' &
    CLAUDE_PID=$!

    # Monitor activity
    LAST_ACTIVITY=$(date +%s)
    LAST_LOG_LINE_COUNT=0
    IDLE_WARNING_SHOWN=0

    while ps -p $CLAUDE_PID > /dev/null 2>&1; do
        sleep 5

        # Check container logs for new activity
        CURRENT_LOG_LINE_COUNT=$(docker logs --tail 50 claude-code-sandbox 2>&1 | wc -l)

        if [ "$CURRENT_LOG_LINE_COUNT" -ne "$LAST_LOG_LINE_COUNT" ]; then
            LAST_ACTIVITY=$(date +%s)
            LAST_LOG_LINE_COUNT=$CURRENT_LOG_LINE_COUNT
            IDLE_WARNING_SHOWN=0
        fi

        # Check idle time
        CURRENT_TIME=$(date +%s)
        IDLE_SECONDS=$((CURRENT_TIME - LAST_ACTIVITY))

        if [ $IDLE_SECONDS -gt $IDLE_TIMEOUT ]; then
            echo ""
            echo "[TIMEOUT] No activity for $IDLE_TIMEOUT seconds. Restarting..."
            echo ""

            # Kill the process
            kill $CLAUDE_PID 2>/dev/null || true
            wait $CLAUDE_PID 2>/dev/null || true

            # Give container a moment to clean up
            sleep 2
            break
        elif [ $IDLE_SECONDS -gt $((IDLE_TIMEOUT * 70 / 100)) ] && [ $IDLE_WARNING_SHOWN -eq 0 ]; then
            echo "[WARNING] Idle for $IDLE_SECONDS seconds (timeout: $IDLE_TIMEOUT)"
            IDLE_WARNING_SHOWN=1
        fi
    done

    # Check if process completed normally
    if ! ps -p $CLAUDE_PID > /dev/null 2>&1; then
        wait $CLAUDE_PID 2>/dev/null
        EXIT_CODE=$?

        if [ $EXIT_CODE -eq 0 ]; then
            echo ""
            echo "[INFO] Claude completed the task. Restarting..."
            echo ""
        else
            echo ""
            echo "[ERROR] Claude failed with exit code $EXIT_CODE. Restarting..."
            echo ""
            sleep 5
        fi
    fi

    sleep 2
done

echo ""
echo "Autonomous mode stopped."
