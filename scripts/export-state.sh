#!/bin/bash
# Export OpenClaw System State
# Creates a snapshot of current configuration (NO SECRETS)

STATE_FILE="${STATE_FILE:-$HOME/.openclaw/workspace/SYSTEM-STATE.md}"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

cat > "$STATE_FILE" << EOF
# OpenClaw System State
> Generated: $DATE

## Git Remote
\`\`\`
$(git remote -v 2>/dev/null || echo "No git remote")
\`\`\`

## Cron Jobs (OpenClaw)
\`\`\`
$(openclaw cron list 2>/dev/null || echo "Unable to list")
\`\`\`

## System Cron Jobs
\`\`\`
$(crontab -l 2>/dev/null || echo "No system crontab")
\`\`\`

## NPM Global Packages
\`\`\`
$(npm list -g --depth=0 2>/dev/null | head -20)
\`\`\`

## Homebrew Packages
\`\`\`
$(brew list 2>/dev/null | head -30)
\`\`\`

## Skills Installed
\`\`\`
$(ls -la ~/.openclaw/skills/ 2>/dev/null | grep "^d" | awk '{print $NF}' | grep -v "^\.$" | grep -v "^\.\.$")
\`\`\`

## Workspace Skills
\`\`\`
$(ls -la ~/.openclaw/workspace/skills/ 2>/dev/null | grep "^d" | awk '{print $NF}' | grep -v "^\.$" | grep -v "^\.\.$")
\`\`\`

## Sensitive Config Locations (DO NOT COMMIT VALUES)
- OpenClaw Config: \`~/.openclaw/openclaw.json\`
  - Contains API keys (environment variables in config)
- Auth profiles: stored in OpenClaw config
- No .env files in workspace

## Healthcheck
- Configured via environment variable: \`HEALTHCHECK_URL\`
- Script: \`~/.openclaw/workspace/scripts/healthcheck.sh\`
- Log: \`~/.openclaw/logs/healthcheck.log\`
EOF

echo "System state exported to $STATE_FILE"
