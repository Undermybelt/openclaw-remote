#!/bin/bash
# OpenClaw Backup Script
# Commits and pushes workspace changes, exports system state

WORKSPACE="$HOME/.openclaw/workspace"
LOG_FILE="$HOME/.openclaw/logs/backup.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

mkdir -p "$(dirname "$LOG_FILE")"
cd "$WORKSPACE" || exit 1

echo "[$DATE] Starting backup..." >> "$LOG_FILE"

# 1. Git status check
CHANGES=$(git status --short)
if [ -z "$CHANGES" ]; then
    echo "[$DATE] No changes to commit" >> "$LOG_FILE"
    exit 0
fi

# 2. Add and commit
git add -A
COMMIT_MSG="Auto backup: $(date '+%Y-%m-%d %H:%M')"
git commit -m "$COMMIT_MSG" >> "$LOG_FILE" 2>&1

# 3. Push to remote
git push >> "$LOG_FILE" 2>&1
PUSH_STATUS=$?

if [ $PUSH_STATUS -eq 0 ]; then
    echo "[$DATE] ✓ Backup successful: $COMMIT_MSG" >> "$LOG_FILE"
else
    echo "[$DATE] ✗ Push failed" >> "$LOG_FILE"
    exit 1
fi
