# 📚 Shared Development Standard
# Part of common standards library used by both Claude and Gemini

# MCP (Model Context Protocol) Configuration

This document outlines the MCP server configurations with automated secret sanitization for secure sharing while maintaining personal working configurations.

## Overview

MCP servers provide additional capabilities to AI tools like accessing GitHub APIs, Grafana monitoring, and documentation services. This setup uses automated template generation to share configurations safely while keeping secrets private.

## Configuration Philosophy

### Two-File System
- **`settings.json`** (gitignored): Your actual working configuration with real tokens
- **`settings-template.json`** (git-tracked): Sanitized template for sharing

### Automated Sanitization
A git pre-commit hook automatically:
- ✅ Detects changes to `settings.json`
- ✅ Generates sanitized `settings-template.json`
- ✅ Replaces secrets with safe placeholders
- ✅ Adds template to your commit automatically

## File Locations

### Claude Code
- **Working config**: `~/.claude/settings.json` (gitignored - contains real secrets)
- **Shared template**: `~/.claude/settings-template.json` (git-tracked - sanitized)
- **Project config**: `.mcp.json` (for project-specific servers)

### Gemini CLI
- **Global config**: `~/.gemini/settings.json` (similar pattern recommended)

## Current Recommended MCP Servers

Based on the sanitized template in this repository:

### Context7 Server
```json
"context7": {
  "command": "npx",
  "args": ["-y", "@upstash/context7-mcp@latest"],
  "type": "stdio"
}
```
**Purpose**: Documentation and code example retrieval

### Supabase Server
```json
"supabase": {
  "command": "npx",
  "args": [
    "-y",
    "@supabase/mcp-server-supabase@latest",
    "--read-only",
    "--project-ref=YOUR_PROJECT_REF_HERE"
  ],
  "env": {
    "SUPABASE_ACCESS_TOKEN": "YOUR_SUPABASE_TOKEN_HERE"
  }
}
```
**Purpose**: Database access and management

### Grafana Server
```json
"grafana": {
  "command": "npx",
  "args": [
    "-y",
    "mcp-remote",
    "http://your-server.example.com:8000/mcp",
    "--allow-http"
  ],
  "type": "stdio"
}
```
**Purpose**: Monitoring and observability data access

## Setup Process

### Initial Setup
1. **Copy template to working config**:
   ```bash
   cd ~/.claude
   cp settings-template.json settings.json
   ```

2. **Add your real credentials**:
   ```bash
   # Edit settings.json with real values:
   # - Replace YOUR_SUPABASE_TOKEN_HERE with actual token
   # - Replace YOUR_PROJECT_REF_HERE with actual project ref
   # - Replace your-server.example.com with actual server
   vim settings.json
   ```

3. **Verify automation works**:
   ```bash
   git add settings.json
   git commit -m "test: verify auto-template generation"
   # Should see: "🔧 Auto-updating settings-template.json..."
   ```

### Adding New MCP Servers

```bash
# 1. Add new server to settings.json with real credentials
vim settings.json

# 2. Commit - template auto-updates with secrets sanitized
git add settings.json
git commit -m "feat: add new-mcp-server configuration"

# 3. Push - shares safe template, keeps secrets local
git push origin main
```

## Authentication Setup

### Secure Token Storage

**For Supabase**:
```bash
# Get your token from Supabase dashboard
# Add to settings.json (not the template!)
"SUPABASE_ACCESS_TOKEN": "sbp_your_actual_token_here"
```

**For GitHub (if using GitHub MCP)**:
```bash
# Store in keychain for maximum security
security add-generic-password -s githubtoken -a github -w "YOUR_GITHUB_PAT_HERE"
```

### Token Rotation Process
1. Update token in `settings.json`
2. Commit changes (template auto-updates with placeholder)
3. Old secrets never exposed in git history

## Security Features

### Automatic Secret Sanitization
The pre-commit hook sanitizes:
- **Supabase tokens**: `sbp_*` → `YOUR_SUPABASE_TOKEN_HERE`
- **GitHub tokens**: `ghp_*` → `YOUR_GITHUB_TOKEN_HERE`
- **OpenAI keys**: `sk-*` → `YOUR_OPENAI_KEY_HERE`
- **Project refs**: Real IDs → `YOUR_PROJECT_REF_HERE`
- **Personal URLs**: `yourserver.com` → `your-server.example.com`
- **User paths**: `/Users/username` → `/Users/YOUR_USERNAME`

### What Gets Shared vs Private

**✅ Shared in Template (git-tracked)**:
- MCP server commands and arguments
- Server types and configurations
- Recommended server list
- Setup instructions

**❌ Private in Settings (gitignored)**:
- Real API tokens and secrets
- Personal project references
- Custom server URLs
- Machine-specific paths

## Troubleshooting

### Git Hook Not Working
```bash
# Ensure hook is executable
chmod +x ~/.claude/.git/hooks/pre-commit

# Test manually
cd ~/.claude
.git/hooks/pre-commit
```

### Missing jq Dependency
```bash
# Install jq for JSON processing
brew install jq
```

### Template Not Updating
1. Verify `settings.json` is staged: `git add settings.json`
2. Check hook output during commit
3. Ensure `jq` is installed and accessible

## Verification Commands

```bash
# Check current MCP server status (Claude Code)
claude
/mcp

# Verify template was sanitized
grep -E "(YOUR_|your-server)" ~/.claude/settings-template.json

# Check for accidentally committed secrets
git log --all --full-history -- settings.json
```

## Team Adoption

### For New Team Members
1. Clone the standards repository to `~/.claude`
2. Copy `settings-template.json` to `settings.json`
3. Replace placeholders with actual credentials
4. Start using Claude Code with shared MCP server patterns

### For Existing Users
1. Update existing `settings.json` with new servers from template
2. Test new MCP servers with `/mcp` command
3. Contribute improvements back via PR process

---

*This automated approach ensures secrets stay private while MCP server configurations are shared safely across the team.*
