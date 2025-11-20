#!/bin/bash
set -e

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >&2
}

log "Replace IP..."

# Set default value if env var is not set
TINKERFORGE_HOST=${TINKERFORGE_HOST:-"localhost"}

# Replace placeholder in config file
sed -i "s/\${TINKERFORGE_HOST}/${TINKERFORGE_HOST}/g" /root/.config/tinkerforge2mqtt/tinkerforge2mqtt.toml


log "Starting brickd..."

# Check if brickd is already running
if pgrep -f "brickd" > /dev/null; then
    log "brickd is already running"
    BRICKD_PID=$(pgrep -f "brickd")
else
    # Start brickd
    brickd > /dev/null 2>&1 &
    BRICKD_PID=$!
    
    # Wait and verify it started
    sleep 1
    if ! kill -0 "$BRICKD_PID" 2>/dev/null; then
        log "ERROR: Failed to start brickd"
        exit 1
    fi
    log "Started brickd with PID: $BRICKD_PID"
fi

cleanup() {
    log "Shutting down..."
    if kill -0 "$BRICKD_PID" 2>/dev/null; then
        log "Stopping brickd (PID: $BRICKD_PID)"
        kill "$BRICKD_PID" 2>/dev/null || true
        # Give it time to shutdown gracefully
        sleep 2
        # Force kill if still running
        if kill -0 "$BRICKD_PID" 2>/dev/null; then
            log "Force killing brickd"
            kill -9 "$BRICKD_PID" 2>/dev/null || true
        fi
        wait "$BRICKD_PID" 2>/dev/null || true
    fi
    log "Shutdown complete"
}
trap cleanup SIGINT SIGTERM EXIT

# Wait for brickd to be ready
log "Waiting for brickd to be ready..."
sleep 2

# Verify cli.py exists and is executable
if [[ ! -f /tinkerforge2mqtt/cli.py ]]; then
    log "ERROR: /tinkerforge2mqtt/cli.py not found"
    exit 1
fi

chmod +x /tinkerforge2mqtt/cli.py

if [[ ! -x /tinkerforge2mqtt/cli.py ]]; then
    log "ERROR: /tinkerforge2mqtt/cli.py is not executable"
    exit 1
fi

cd /tinkerforge2mqtt

log "Discovering devices..."
/tinkerforge2mqtt/.venv-app/bin/python3 -m cli discover || log "WARNING: Discovery failed, continuing anyway..."

log "Starting MQTT publisher..."
exec /tinkerforge2mqtt/.venv-app/bin/python3 -m cli publish-loop