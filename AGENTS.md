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

## Agent-Specific Notes

*(Add any notes, configurations, or patterns that are unique to specific agents here. For project-specific overrides, create an `AGENTS.md` in the project's root directory.)*

Refer to the [Common Patterns & Snippets](./shared/docs/standards/05_COMMON_PATTERNS.md) for information on available tools such as the GitHub CLI (`gh`).
