#!/bin/bash
# OpenClaw Healthcheck Monitor
# Checks gateway process and sends heartbeat to Healthchecks.io

# Get URL from environment variable (do not hardcode!)
HEALTHCHECK_URL="${HEALTHCHECK_URL:-}"
LOG_FILE="${HEALTHCHECK_LOG:-$HOME/.openclaw/logs/healthcheck.log}"

# Create logs directory if not exists
mkdir -p "$(dirname "$LOG_FILE")"

# Check if URL is configured
if [ -z "$HEALTHCHECK_URL" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') ✗ HEALTHCHECK_URL not set" >> "$LOG_FILE"
    exit 1
fi

# Check if OpenClaw gateway is running
GATEWAY_COUNT=$(ps aux | grep -c "[o]penclaw-gateway")

if [ "$GATEWAY_COUNT" -gt 0 ]; then
    # Gateway is running, send success ping
    curl -fsS -m 10 --retry 5 "$HEALTHCHECK_URL" > /dev/null 2>&1
    echo "$(date '+%Y-%m-%d %H:%M:%S') ✓ Gateway running" >> "$LOG_FILE"
    exit 0
else
    # Gateway not running, send failure ping
    curl -fsS -m 10 --retry 5 "$HEALTHCHECK_URL/fail" > /dev/null 2>&1
    echo "$(date '+%Y-%m-%d %H:%M:%S') ✗ Gateway NOT running" >> "$LOG_FILE"
    exit 1
fi
