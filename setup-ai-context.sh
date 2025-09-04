#!/bin/bash
set -e

# Slack notification function
send_slack_notification() {
    local message="$1"
    local webhook_url="${SLACK_WEBHOOK_URL:-}"
    
    if [ -n "$webhook_url" ]; then
        curl -s -X POST -H 'Content-type: application/json' \
            --data "{\"channel\":\"#monitoring\",\"text\":\"$message\"}" \
            "$webhook_url" > /dev/null 2>&1 || true
    fi
}

# Get hostname and user for notifications
HOSTNAME=$(hostname)
USER=$(whoami)
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

if [ "$(pwd)" = "$HOME" ]; then
    echo "🏠 Setting up global context..."
    rm -rf ~/.claude ~/.gemini ~/.windsurf ~/.bjzy 2>/dev/null || true
    git clone https://github.com/BrianInAz/context-standards.git ~/.bjzy
    ln -sf ~/.bjzy ~/.claude
    ln -sf ~/.bjzy ~/.gemini
    ln -sf ~/.bjzy ~/.windsurf
    cd ~/.bjzy && ln -sf AGENTS.md CLAUDE.md GEMINI.md
    
    echo "✅ Global context ready at ~/.bjzy/"
    send_slack_notification "✅ AI Context: Global setup completed on \`$HOSTNAME\` by \`$USER\` at $TIMESTAMP"
    
else
    echo "📁 Setting up project context..."
    curl -s https://raw.githubusercontent.com/BrianInAz/context-standards/main/AGENTS.md > AGENTS.md
    
    mkdir -p .claude .gemini .roo
    ln -sf ../AGENTS.md .claude/CLAUDE.md .gemini/GEMINI.md .roo/roo.md
    ln -sf AGENTS.md .cursorrules
    
    PROJECT_PATH=$(pwd)
    PROJECT_NAME=$(basename "$PROJECT_PATH")
    
    echo "✅ Project context created - edit ./AGENTS.md to customize"
    send_slack_notification "📁 AI Context: Project setup completed for \`$PROJECT_NAME\` on \`$HOSTNAME\` by \`$USER\` at $TIMESTAMP"
fi
