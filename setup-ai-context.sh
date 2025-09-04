#!/bin/bash
set -e

# AI Context Setup Script - v1.1
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
    ln -sfn ~/.bjzy ~/.claude
    ln -sfn ~/.bjzy ~/.gemini
    ln -sfn ~/.bjzy ~/.windsurf
    cd ~/.bjzy && ln -sf AGENTS.md CLAUDE.md && ln -sf AGENTS.md GEMINI.md
    
    echo "✅ Global context ready at ~/.bjzy/"
    send_slack_notification "✅ AI Context: Global setup completed on \`$HOSTNAME\` by \`$USER\` at $TIMESTAMP"
    
else
    echo "📁 Setting up project context..."
    
    # Smart AGENTS.md handling
    if [ -f "AGENTS.md" ]; then
        echo "🔄 Existing AGENTS.md found - performing intelligent merge..."
        
        # Backup existing file
        cp AGENTS.md AGENTS.md.backup
        
        # Download latest template
        curl -s https://raw.githubusercontent.com/BrianInAz/context-standards/main/AGENTS.md > AGENTS.md.new
        
        # Simple merge strategy: preserve existing if it has project-specific content
        # Check if existing file has been customized (more than template + few lines)
        EXISTING_LINES=$(wc -l < AGENTS.md)
        TEMPLATE_LINES=$(wc -l < AGENTS.md.new)
        
        if [ "$EXISTING_LINES" -gt $((TEMPLATE_LINES + 5)) ]; then
            echo "🎯 Preserving customized AGENTS.md (${EXISTING_LINES} lines vs ${TEMPLATE_LINES} template)"
            rm AGENTS.md.new
            echo "💾 Backed up to AGENTS.md.backup"
            echo "📝 Template saved for reference - run 'curl -s https://raw.githubusercontent.com/BrianInAz/context-standards/main/AGENTS.md > AGENTS.md.template' to see latest"
        else
            echo "🔄 Updating to latest template (minimal customization detected)"
            mv AGENTS.md.new AGENTS.md
            echo "💾 Previous version saved as AGENTS.md.backup"
        fi
    else
        echo "📥 Downloading AGENTS.md template..."
        curl -s https://raw.githubusercontent.com/BrianInAz/context-standards/main/AGENTS.md > AGENTS.md
    fi
    
    mkdir -p .claude .gemini .roo
    ln -sf ../AGENTS.md .claude/CLAUDE.md
    ln -sf ../AGENTS.md .gemini/GEMINI.md  
    ln -sf ../AGENTS.md .roo/roo.md
    ln -sf AGENTS.md .cursorrules
    
    PROJECT_PATH=$(pwd)
    PROJECT_NAME=$(basename "$PROJECT_PATH")
    
    echo "✅ Project context created - edit ./AGENTS.md to customize"
    send_slack_notification "📁 AI Context: Project setup completed for \`$PROJECT_NAME\` on \`$HOSTNAME\` by \`$USER\` at $TIMESTAMP"
fi
