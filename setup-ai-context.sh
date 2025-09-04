#!/bin/bash
set -e

# AI Context Setup Script - v2.0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Error handling
cleanup() {
    if [ -n "$TEMP_FILE" ] && [ -f "$TEMP_FILE" ]; then
        rm -f "$TEMP_FILE"
    fi
}
trap cleanup EXIT

# Utility functions
log_error() {
    echo -e "${RED}❌ Error: $1${NC}" >&2
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check for required tools
check_requirements() {
    local missing_tools=()
    
    for tool in git curl diff; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            missing_tools+=("$tool")
        fi
    done
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        log_error "Missing required tools: ${missing_tools[*]}"
        log_info "Please install missing tools and try again"
        exit 1
    fi
}

# Safe curl with error handling
safe_curl() {
    local url="$1"
    local output="$2"
    local max_retries=3
    local retry=0
    
    while [ $retry -lt $max_retries ]; do
        if curl -f -s --connect-timeout 10 --max-time 30 "$url" > "$output"; then
            return 0
        fi
        retry=$((retry + 1))
        if [ $retry -lt $max_retries ]; then
            log_warning "Download failed, retrying ($retry/$max_retries)..."
            sleep 2
        fi
    done
    
    log_error "Failed to download from $url after $max_retries attempts"
    return 1
}

# Validate symlink creation
validate_symlink() {
    local link="$1"
    local target="$2"
    
    if [ ! -L "$link" ]; then
        log_error "Failed to create symlink: $link"
        return 1
    fi
    
    if [ ! -e "$link" ]; then
        log_error "Symlink created but target not found: $link -> $target"
        return 1
    fi
    
    return 0
}

# Show help
show_help() {
    cat << EOF
${BLUE}AI Context Setup Script v2.0${NC}

${YELLOW}USAGE:${NC}
  bash setup-ai-context.sh [OPTIONS]

${YELLOW}MODES:${NC}
  ${GREEN}Global Setup${NC}  - Run from home directory (~)
                   Creates ~/.bjzy with full repository
                   Sets up symlinks for all AI agents
                   
  ${GREEN}Project Setup${NC} - Run from any project directory
                   Downloads AGENTS.md template
                   Creates project-specific agent directories

${YELLOW}OPTIONS:${NC}
  -h, --help       Show this help message
  --uninstall      Remove AI context setup
  --force          Force reinstall (global mode only)

${YELLOW}EXAMPLES:${NC}
  # Global setup
  cd ~ && bash setup-ai-context.sh
  
  # Project setup
  cd ~/my-project && bash setup-ai-context.sh
  
  # Clean removal
  bash setup-ai-context.sh --uninstall

${YELLOW}ENVIRONMENT:${NC}
  SLACK_WEBHOOK_URL    Optional Slack webhook for notifications

EOF
}

# Uninstall function
uninstall_context() {
    log_info "Removing AI context setup..."
    
    # Global cleanup
    if [ -d "$HOME/.bjzy" ]; then
        rm -rf "$HOME/.bjzy"
        log_success "Removed ~/.bjzy"
    fi
    
    for link in "$HOME/.claude" "$HOME/.gemini" "$HOME/.windsurf"; do
        if [ -L "$link" ]; then
            rm "$link"
            log_success "Removed $(basename "$link")"
        fi
    done
    
    # Project cleanup (if in project directory)
    if [ "$(pwd)" != "$HOME" ]; then
        for file in AGENTS.md .cursorrules; do
            if [ -f "$file" ]; then
                rm "$file"
                log_success "Removed $file"
            fi
        done
        
        for dir in .claude .gemini .roo; do
            if [ -d "$dir" ]; then
                rm -rf "$dir"
                log_success "Removed $dir/"
            fi
        done
    fi
    
    log_success "AI context setup removed successfully"
    exit 0
}

# Parse command line arguments
FORCE_INSTALL=false
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        --uninstall)
            uninstall_context
            ;;
        --force)
            FORCE_INSTALL=true
            shift
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
    shift
done

# Check requirements before proceeding
check_requirements

# Slack notification function
send_slack_notification() {
    local message="$1"
    local webhook_url="${SLACK_WEBHOOK_URL:-}"
    
    if [ -n "$webhook_url" ]; then
        if ! curl -s -X POST -H 'Content-type: application/json' \
            --data "{\"channel\":\"#monitoring\",\"text\":\"$message\"}" \
            "$webhook_url" > /dev/null 2>&1; then
            log_warning "Failed to send Slack notification"
        fi
    fi
}

# Safe git clone with error handling
safe_git_clone() {
    local repo_url="$1"
    local target_dir="$2"
    local max_retries=3
    local retry=0
    
    while [ $retry -lt $max_retries ]; do
        if git clone "$repo_url" "$target_dir" 2>/dev/null; then
            return 0
        fi
        retry=$((retry + 1))
        if [ $retry -lt $max_retries ]; then
            log_warning "Git clone failed, retrying ($retry/$max_retries)..."
            rm -rf "$target_dir" 2>/dev/null || true
            sleep 2
        fi
    done
    
    log_error "Failed to clone repository after $max_retries attempts"
    return 1
}

# Get hostname and user for notifications
HOSTNAME=$(hostname)
USER=$(whoami)
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

if [ "$(pwd)" = "$HOME" ]; then
    log_info "Setting up global context..."
    
    # Check if already installed and not forcing
    if [ -d "$HOME/.bjzy" ] && [ "$FORCE_INSTALL" = false ]; then
        log_warning "Global context already exists at ~/.bjzy"
        log_info "Use --force to reinstall or --uninstall to remove"
        exit 0
    fi
    
    # Clean up existing installation
    rm -rf ~/.claude ~/.gemini ~/.windsurf ~/.bjzy 2>/dev/null || true
    
    # Clone repository with error handling
    if ! safe_git_clone "https://github.com/BrianInAz/context-standards.git" "$HOME/.bjzy"; then
        log_error "Failed to clone context standards repository"
        exit 1
    fi
    
    # Create and validate symlinks
    ln -sfn "$HOME/.bjzy" "$HOME/.claude" && validate_symlink "$HOME/.claude" "$HOME/.bjzy"
    ln -sfn "$HOME/.bjzy" "$HOME/.gemini" && validate_symlink "$HOME/.gemini" "$HOME/.bjzy"
    ln -sfn "$HOME/.bjzy" "$HOME/.windsurf" && validate_symlink "$HOME/.windsurf" "$HOME/.bjzy"
    
    # Create agent-specific symlinks within .bjzy
    cd "$HOME/.bjzy" || exit 1
    ln -sf AGENTS.md CLAUDE.md && validate_symlink CLAUDE.md AGENTS.md
    ln -sf AGENTS.md GEMINI.md && validate_symlink GEMINI.md AGENTS.md
    
    log_success "Global context ready at ~/.bjzy/"
    send_slack_notification "✅ AI Context: Global setup completed on \`$HOSTNAME\` by \`$USER\` at $TIMESTAMP"
    
else
    log_info "Setting up project context..."
    
    # Create temporary file for downloads
    TEMP_FILE=$(mktemp)
    
    # Smart AGENTS.md handling
    if [ -f "AGENTS.md" ]; then
        log_info "Existing AGENTS.md found - checking for differences..."
        
        # Download latest template for comparison
        if ! safe_curl "https://raw.githubusercontent.com/BrianInAz/context-standards/main/AGENTS.md" "$TEMP_FILE"; then
            log_error "Failed to download latest template for comparison"
            exit 1
        fi
        
        # Check if files are different
        if ! diff -q AGENTS.md "$TEMP_FILE" > /dev/null 2>&1; then
            echo ""
            log_warning "IMPORTANT: Your AGENTS.md differs from the latest template!"
            echo ""
            
            # Backup existing file
            cp AGENTS.md AGENTS.md.backup
            log_success "Backed up your version to AGENTS.md.backup"
            echo ""
            
            # Show the diff
            log_info "Here's what changed:"
            echo -e "${BLUE}--- Your current AGENTS.md"
            echo -e "+++ Latest template${NC}"
            diff -u AGENTS.md "$TEMP_FILE" || true
            echo ""
            
            # Update to new template
            mv "$TEMP_FILE" AGENTS.md
            log_success "Updated to latest template"
            echo ""
            log_warning "Next Steps:"
            echo "   1. Review the diff above"
            echo "   2. Edit AGENTS.md to add back your customizations"
            echo -e "   3. Compare with backup: ${GREEN}diff AGENTS.md.backup AGENTS.md${NC}"
            echo ""
        else
            log_success "Your AGENTS.md matches the latest template - no changes needed"
        fi
    else
        log_info "Downloading AGENTS.md template..."
        if ! safe_curl "https://raw.githubusercontent.com/BrianInAz/context-standards/main/AGENTS.md" AGENTS.md; then
            log_error "Failed to download AGENTS.md template"
            exit 1
        fi
    fi
    
    # Create directories and symlinks with validation
    mkdir -p .claude .gemini .roo
    
    ln -sf ../AGENTS.md .claude/CLAUDE.md && validate_symlink .claude/CLAUDE.md ../AGENTS.md
    ln -sf ../AGENTS.md .gemini/GEMINI.md && validate_symlink .gemini/GEMINI.md ../AGENTS.md
    ln -sf ../AGENTS.md .roo/roo.md && validate_symlink .roo/roo.md ../AGENTS.md
    ln -sf AGENTS.md .cursorrules && validate_symlink .cursorrules AGENTS.md
    
    PROJECT_PATH=$(pwd)
    PROJECT_NAME=$(basename "$PROJECT_PATH")
    
    log_success "Project context created - edit ./AGENTS.md to customize"
    send_slack_notification "📁 AI Context: Project setup completed for \`$PROJECT_NAME\` on \`$HOSTNAME\` by \`$USER\` at $TIMESTAMP"
fi
