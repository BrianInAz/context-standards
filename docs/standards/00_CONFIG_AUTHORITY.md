# 📚 Shared Development Standard
# Part of common standards library used by both Claude and Gemini

# Configuration Authority and Hierarchy

This document establishes the definitive hierarchy for how development standards are loaded and applied. It is the single source of truth for resolving conflicts and ensuring predictable behavior across all projects.

## 1. The Hierarchy of Precedence

Configuration is loaded from a single location. The first configuration file found is the only one used. The search follows this strict order of precedence, from highest to lowest:

**1. Project-Specific Configuration (Highest Priority)**
   - **Location**: A tool-specific file in the project root (e.g., `GEMINI.md`, `CLAUDE.md`, `COPILOT.md`).
   - **Behavior**: If a configuration file exists within the project's directory, it **completely overrides** any other settings. It is used as the sole source of instructions for that project.
   - **Use Case**: For projects that require unique standards, different from your personal defaults.

**2. User-Specific Configuration (Default)**
   - **Location**: A tool-specific file in your user standards directory (e.g., `~/.ai-dev-standards/GEMINI.md`).
   - **Behavior**: If no project-specific configuration is found, the tool uses this file as the default set of standards.
   - **Use Case**: Your personal, universal standards that apply to any project without its own specific rules.

**3. Tool Default (Lowest Priority)**
   - **Location**: Built-in to the AI tool.
   - **Behavior**: If neither a project-specific nor a user-specific configuration is found, the tool will use its own generic, built-in settings.

## 2. The "All-or-Nothing" Rule

It is critical to understand that these configuration files are **not merged**. The system employs an "all-or-nothing" approach:

- The very first `.md` file found in the hierarchy is used exclusively.
- All other configuration files in lower-priority locations are **completely ignored**.

For example, if a project's `GEMINI.md` contains only the word "YES", then "YES" becomes the *entire* set of instructions for that project. The comprehensive user-level standards will not be loaded.

## 3. Best Practice for New Projects

To ensure a consistent and efficient workflow when starting a new project, follow this process:

1.  **Decide if the project needs custom standards.**
2.  **If yes:**
    - Copy the contents of your user-level `~/.ai-dev-standards/GEMINI.md` into a new `GEMINI.md` file in the project's root directory.
    - Modify the new, project-level `GEMINI.md` to fit the project's specific needs.
3.  **If no:**
    - Do nothing. The project will automatically inherit your user-level standards.

This approach ensures that you always start with a strong, sane set of defaults while maintaining the flexibility to adapt to project-specific requirements.
