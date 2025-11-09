#!/bin/bash
set -euo pipefail

brickd &
BRICKD_PID=$!

cleanup() {
	echo "[entrypoint] Shutting down..."
	if kill -0 "$BRICKD_PID" 2>/dev/null; then
		kill "$BRICKD_PID" 2>/dev/null || true
		wait "$BRICKD_PID" 2>/dev/null || true
	fi
}
trap cleanup SIGINT SIGTERM

# Use pre-built virtual env if available, else fall back to bootstrap cli
APP_BIN="/tinkerforge2mqtt/.venv-app/bin/tinkerforge2mqtt_app"
if [ -x "$APP_BIN" ]; then
	echo "[entrypoint] Using app binary: $APP_BIN"
	exec "$APP_BIN" publish-loop
else
	echo "[entrypoint] App binary not found, falling back to cli bootstrap"
	exec python3 /tinkerforge2mqtt/cli.py publish-loop
fi
