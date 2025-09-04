# 📚 Shared Development Standard
# Part of common standards library used by both Claude and Gemini

# Common Patterns & Snippets

This document contains common patterns, snippets, and information about tools available to all AI agents.

## Available Command-Line Tools

### GitHub CLI (`gh`)

All agents have access to the official GitHub CLI tool, `gh`. The tool is pre-authenticated and can be used to interact with GitHub repositories for tasks such as:

- Cloning repositories
- Checking out pull requests
- Creating gists
- Inspecting issues

**Note:** While the `gh` tool is available, direct integration with the GitHub MCP (Model Context Protocol) is not currently supported due to limitations in handling authenticated SSE connections.
