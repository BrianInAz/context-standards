# 🏠 PERSONAL Development Standards
# This is your USER/PERSONAL agent context file
# Creating AGENTS.md in a project directory overrides this file
# See: Configuration Authority in ./shared/docs/standards/00_CONFIG_AUTHORITY.md

# Universal Development Standards

This document outlines the primary development standards and best practices when working with AI agents. It serves as the main entry point, linking to a collection of modular and authoritative standards documents.

## Core Principle: Configuration Authority

Before all else, it is critical to understand how standards are loaded. This project uses a hierarchical model where the first configuration file found is the only one used. For a complete explanation of this "all-or-nothing" rule, please see the authoritative guide:

- [**Configuration Authority and Hierarchy**](./shared/docs/standards/00_CONFIG_AUTHORITY.md)

## Universal Development Guidelines

These guidelines represent your personal, universal standards that apply to any project without its own specific rules. They are organized into modular documents for clarity and maintainability.

- [**01: Coding Standards**](./shared/docs/standards/01_CODING_STANDARDS.md)
- [**02: Git Workflow & Commits**](./shared/docs/standards/02_GITFLOW.md)
- [**03: Documentation Standards**](./shared/docs/standards/03_DOCUMENTATION.md)
- [**04: Testing Procedures**](./shared/docs/standards/04_TESTING.md)
- [**05: Common Patterns & Snippets**](./shared/docs/standards/05_COMMON_PATTERNS.md)
- [**06: Security Guidelines**](./shared/docs/standards/06_SECURITY.md)
- [**07: MCP Configuration**](./shared/docs/standards/07_MCP_CONFIGURATION.md)

## DevOps Integration

### AI Context Setup Workflow

This repository provides automated setup for unified AI agent context management across all development environments.

#### Quick Setup Commands
```bash
# Global context (run once per machine in home directory)
export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
bash <(curl -s https://raw.githubusercontent.com/BrianInAz/context-standards/main/setup-ai-context.sh)

# Project context (run in each project directory)
bash <(curl -s https://raw.githubusercontent.com/BrianInAz/context-standards/main/setup-ai-context.sh)
```

#### Workflow Integration
- **New Machine Setup**: Run global setup to establish `~/.bjzy/` as unified context source
- **New Project Setup**: Run project setup to create local `AGENTS.md` with agent-specific symlinks
- **Context Customization**: Edit project `AGENTS.md` for project-specific requirements
- **Slack Monitoring**: Automatic notifications to `#monitoring` channel on setup completion

#### Agent Compatibility Matrix
| Agent | Global Context | Project Context | Config File |
|-------|----------------|-----------------|-------------|
| Claude | `~/.claude/CLAUDE.md` | `.claude/CLAUDE.md` | → `AGENTS.md` |
| Gemini | `~/.gemini/GEMINI.md` | `.gemini/GEMINI.md` | → `AGENTS.md` |
| Cursor | - | `.cursorrules` | → `AGENTS.md` |
| Windsurf | `~/.windsurf/AGENTS.md` | - | Uses global |
| Roo | - | `.roo/roo.md` | → `AGENTS.md` |

#### Context Resolution Hierarchy
1. **Project Directory**: `./AGENTS.md` overrides global context
2. **Parent Directories**: Searches up directory tree for context
3. **Global Fallback**: Uses `~/.bjzy/AGENTS.md` as default

This workflow ensures consistent AI agent behavior across all projects while allowing project-specific customization when needed.

## Agent-Specific Notes

*(Add any notes, configurations, or patterns that are unique to specific agents here. For project-specific overrides, create an `AGENTS.md` in the project's root directory.)*

Refer to the [Common Patterns & Snippets](./shared/docs/standards/05_COMMON_PATTERNS.md) for information on available tools such as the GitHub CLI (`gh`).
