# AI Context Standards

Unified AI agent context management for all development environments. Single source of truth for Claude, Gemini, Cursor, Windsurf, and other AI agents.

## Quick Setup

### Global Context (Home Directory)
```bash
export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
bash <(curl -s https://raw.githubusercontent.com/BrianInAz/context-standards/main/setup-ai-context.sh)
```

### Project Context
```bash
mkdir my-project && cd my-project
bash <(curl -s https://raw.githubusercontent.com/BrianInAz/context-standards/main/setup-ai-context.sh)
```

## How It Works

### Hierarchical Context Resolution
1. **Project Directory**: Uses local `AGENTS.md` if present
2. **Parent Directories**: Searches up the directory tree
3. **Global Fallback**: Uses `~/.bjzy/AGENTS.md` as default

### Agent Compatibility
| Agent | Context File | Location |
|-------|-------------|----------|
| **Claude** | `CLAUDE.md` | `.claude/` or `~/.claude/` |
| **Gemini** | `GEMINI.md` | `.gemini/` or `~/.gemini/` |  
| **Cursor** | `.cursorrules` | Project root |
| **Windsurf** | `AGENTS.md` | `~/.windsurf/` |
| **Roo** | `roo.md` | `.roo/` |

### Directory Structure

**Global Setup:**
```
~/.bjzy/           # Master repository
├── AGENTS.md      # Unified context file
├── CLAUDE.md      # → AGENTS.md (symlink)
├── GEMINI.md      # → AGENTS.md (symlink) 
└── shared/        # Documentation & standards

~/.claude/         # → ~/.bjzy (symlink)
~/.gemini/         # → ~/.bjzy (symlink)
~/.windsurf/       # → ~/.bjzy (symlink)
```

**Project Setup:**
```
my-project/
├── AGENTS.md      # Project-specific context
├── .cursorrules   # → AGENTS.md (symlink)
├── .claude/
│   └── CLAUDE.md  # → ../AGENTS.md (symlink)
├── .gemini/
│   └── GEMINI.md  # → ../AGENTS.md (symlink)
└── .roo/
    └── roo.md     # → ../AGENTS.md (symlink)
```

## Workflow Integration

### Development Setup
1. **New Machine**: Run global setup once in home directory
2. **New Project**: Run project setup in project directory
3. **Customize**: Edit `AGENTS.md` for project-specific requirements

### Slack Notifications
Setup sends notifications to `#monitoring` channel:
- `✅ AI Context: Global setup completed on hostname by user`
- `📁 AI Context: Project setup for project-name on hostname by user`

### Git Integration
- Global context managed via this repository
- Project contexts are independent and git-ignored by default
- Use `.gitignore` entries for agent directories:
  ```gitignore
  .claude/
  .gemini/
  .roo/
  .cursorrules
  ```

## Standards Documentation

The `shared/` directory contains modular development standards:

- **[Configuration Authority](./shared/docs/standards/00_CONFIG_AUTHORITY.md)** - Hierarchy rules
- **[Coding Standards](./shared/docs/standards/01_CODING_STANDARDS.md)** - Code style guide  
- **[Git Workflow](./shared/docs/standards/02_GITFLOW.md)** - Commit & branch patterns
- **[Documentation](./shared/docs/standards/03_DOCUMENTATION.md)** - Documentation standards
- **[Testing](./shared/docs/standards/04_TESTING.md)** - Testing procedures
- **[Common Patterns](./shared/docs/standards/05_COMMON_PATTERNS.md)** - Reusable patterns
- **[Security](./shared/docs/standards/06_SECURITY.md)** - Security guidelines
- **[MCP Configuration](./shared/docs/standards/07_MCP_CONFIGURATION.md)** - Model Context Protocol

## Migration from Legacy

### From Separate Repos
If migrating from separate `claude-standards` or `gemini-standards`:

1. **Backup existing contexts:**
   ```bash
   mv ~/.claude ~/.claude-backup
   mv ~/.gemini ~/.gemini-backup
   ```

2. **Run global setup** (will create unified structure)

3. **Merge custom content** from backups into new `AGENTS.md`

### Project Migration
For projects with existing `.claude/` or `.gemini/` directories:

1. **Backup project contexts:**
   ```bash
   cp .claude/CLAUDE.md CLAUDE-backup.md
   cp .gemini/GEMINI.md GEMINI-backup.md
   ```

2. **Run project setup** (creates unified structure)

3. **Merge custom content** into new `AGENTS.md`

## Troubleshooting

### Script Fails
```bash
# Check webhook (optional)
echo $SLACK_WEBHOOK_URL

# Manual cleanup if needed
rm -rf ~/.claude ~/.gemini ~/.windsurf ~/.bjzy

# Re-run setup
bash <(curl -s https://raw.githubusercontent.com/BrianInAz/context-standards/main/setup-ai-context.sh)
```

### Symlinks Broken
```bash
# Check symlinks
ls -la ~/.claude ~/.gemini ~/.windsurf
ls -la ~/.bjzy/CLAUDE.md ~/.bjzy/GEMINI.md

# Recreate if needed
cd ~/.bjzy
ln -sf AGENTS.md CLAUDE.md
ln -sf AGENTS.md GEMINI.md
```

### Agent Not Finding Context
1. **Check file exists:** `cat ~/.bjzy/AGENTS.md`
2. **Check symlinks:** `ls -la ~/.claude/CLAUDE.md` 
3. **Check project override:** `ls -la ./AGENTS.md`

## Contributing

1. **Fork this repository**
2. **Create feature branch:** `git checkout -b feature/improvement`
3. **Test thoroughly** on clean environment
4. **Submit pull request** with clear description

### Testing Changes
```bash
# Test global setup
cd ~ && bash /path/to/modified/setup-ai-context.sh

# Test project setup  
mkdir test-project && cd test-project
bash /path/to/modified/setup-ai-context.sh
```

## Architecture Decisions

### Why Unified AGENTS.md?
- **Single source of truth** - reduces context drift between agents
- **Industry standard** - 20,000+ repositories use AGENTS.md
- **Backward compatibility** - symlinks preserve existing workflows
- **Easy maintenance** - one file to update vs multiple

### Why Symlinks?
- **No duplication** - changes propagate automatically
- **Agent compatibility** - each agent finds expected filename
- **Performance** - no file copying or syncing required
- **Transparency** - easy to see what's linked where

### Why Hierarchical Resolution?
- **Project flexibility** - override global standards per project
- **Team consistency** - shared global standards by default
- **Development phases** - different contexts for different environments
