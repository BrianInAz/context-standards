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
        echo "🔍 Existing AGENTS.md found - checking for differences..."
        
        # Download latest template for comparison
        curl -s https://raw.githubusercontent.com/BrianInAz/context-standards/main/AGENTS.md > AGENTS.md.new
        
        # Check if files are different
        if ! diff -q AGENTS.md AGENTS.md.new > /dev/null 2>&1; then
            echo ""
            echo "⚠️  \033[1;33mIMPORTANT: Your AGENTS.md differs from the latest template!\033[0m"
            echo ""
            
            # Backup existing file
            cp AGENTS.md AGENTS.md.backup
            echo "💾 \033[1;32mBacked up your version to AGENTS.md.backup\033[0m"
            echo ""
            
            # Show the diff
            echo "📊 \033[1;34mHere's what changed:\033[0m"
            echo "\033[0;36m--- Your current AGENTS.md"
            echo "+++ Latest template\033[0m"
            diff -u AGENTS.md AGENTS.md.new || true
            echo ""
            
            # Update to new template
            mv AGENTS.md.new AGENTS.md
            echo "🔄 \033[1;32mUpdated to latest template\033[0m"
            echo ""
            echo "🛠️  \033[1;33mNext Steps:\033[0m"
            echo "   1. Review the diff above"
            echo "   2. Edit AGENTS.md to add back your customizations"
            echo "   3. Compare with backup: \033[0;32mdiff AGENTS.md.backup AGENTS.md\033[0m"
            echo ""
        else
            echo "✅ Your AGENTS.md matches the latest template - no changes needed"
            rm AGENTS.md.new
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
