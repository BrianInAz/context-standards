# 📚 Shared Development Standard
# Part of common standards library used by both Claude and Gemini

# GitFlow Workflow Standard

## <3 CRITICAL: Git Branching Strategy

**� MANDATORY FOR ALL CONTRIBUTORS �**

This is the standard GitFlow branching strategy that must be followed across all projects.

## Core Principles

-  **Branch from `develop`** (NOT `main`)
-  **Target `develop`** for all feature/bugfix PRs
-  **`main` is production-ready releases only**
-  **Use proper branch naming**: `feature/`, `bugfix/`, `hotfix/`

## Workflow Commands

### Starting New Work
```bash
#  CORRECT - Start from develop
git checkout develop
git pull origin develop
git checkout -b feature/my-feature

# Work on your changes...
git add .
git commit -m "feat: implement new feature"
git push origin feature/my-feature

# Create PR targeting develop
gh pr create --base develop
```

### Branch Naming Conventions
```bash
# Features
feature/user-authentication
feature/payment-integration
feature/dashboard-ui

# Bug fixes
bugfix/login-error
bugfix/database-connection
bugfix/ui-responsive-issues

# Hotfixes (emergency production fixes)
hotfix/security-patch
hotfix/critical-bug-fix
```

### What NOT to Do
```bash
# L WRONG - Never target main for features
gh pr create --base main  # This will be rejected!

# L WRONG - Don't branch from main for features
git checkout main
git checkout -b feature/my-feature
```

## Branch Purposes

### `main` Branch
- **Purpose**: Production-ready releases only
- **Protection**: Highly protected, no direct commits
- **Updates**: Only through release merges from `develop`
- **Deployments**: Automatic deployments to production

### `develop` Branch
- **Purpose**: Integration branch for features
- **Target**: All feature and bugfix PRs
- **Testing**: Continuous integration testing
- **Deployments**: Staging/development environments

### Feature Branches
- **Naming**: `feature/description`
- **Source**: Branch from `develop`
- **Target**: Merge back to `develop`
- **Lifespan**: Short-lived, deleted after merge

### Bugfix Branches
- **Naming**: `bugfix/description`
- **Source**: Branch from `develop`
- **Target**: Merge back to `develop`
- **Purpose**: Non-critical bug fixes

### Hotfix Branches
- **Naming**: `hotfix/description`
- **Source**: Branch from `main` (emergency only)
- **Target**: Merge to both `main` and `develop`
- **Purpose**: Critical production fixes

## Release Process

### Regular Releases
1. Features are merged into `develop`
2. `develop` is tested thoroughly
3. Create release branch: `release/v1.2.0`
4. Final testing and bug fixes
5. Merge to `main` and tag
6. Merge back to `develop`

### Emergency Hotfixes
1. Branch from `main`: `hotfix/critical-fix`
2. Fix the issue and test
3. Merge to `main` immediately
4. Tag the hotfix release
5. Merge back to `develop`

## Common Scenarios

### Working on a Feature
```bash
# 1. Ensure you're on develop and up to date
git checkout develop
git pull origin develop

# 2. Create feature branch
git checkout -b feature/user-profile

# 3. Work and commit changes
git add .
git commit -m "feat: add user profile component"

# 4. Push and create PR
git push origin feature/user-profile
gh pr create --base develop --title "Add user profile component"
```

### Fixing a Bug
```bash
# Same process as feature, but different naming
git checkout develop
git pull origin develop
git checkout -b bugfix/form-validation

# Fix the bug...
git add .
git commit -m "fix: resolve form validation error"

git push origin bugfix/form-validation
gh pr create --base develop --title "Fix form validation error"
```

### Emergency Production Fix
```bash
# ONLY for critical production issues
git checkout main
git pull origin main
git checkout -b hotfix/security-patch

# Apply the fix...
git add .
git commit -m "hotfix: patch security vulnerability"

# Create PR to main (requires admin approval)
git push origin hotfix/security-patch
gh pr create --base main --title "HOTFIX: Security vulnerability patch"

# After merging to main, also merge to develop
gh pr create --base develop --title "Merge hotfix back to develop"
```

## Enforcement

### Automated Checks
- Branch protection rules prevent direct commits to `main`
- Required PR reviews before merging
- Status checks must pass (CI/CD, tests)
- PRs targeting wrong branch are automatically rejected

### Manual Review Process
- All PRs reviewed by maintainers
- Verification of proper branching strategy
- Code quality and security checks
- Testing requirements validation

## Integration with AI Reviews

AI-powered code review tools can be configured to:
- Automatically review PRs targeting `develop`
- Check for proper GitFlow compliance
- Verify branch naming conventions
- Ensure code quality standards

## Quick Reference

| Action | Command | Notes |
|--------|---------|-------|
| Start feature | `git checkout -b feature/name` | From develop |
| Start bugfix | `git checkout -b bugfix/name` | From develop |
| Start hotfix | `git checkout -b hotfix/name` | From main (emergency) |
| Create PR | `gh pr create --base develop` | Most common |
| Emergency PR | `gh pr create --base main` | Hotfixes only |

## Non-Compliance Consequences

**PRs that violate GitFlow will be:**
- Automatically rejected by branch protection
- Closed with explanation if manually created
- Required to be recreated with proper targeting

**Remember**: This workflow protects production stability and ensures smooth collaboration.

---
*This GitFlow standard applies to all repositories and is non-negotiable for production systems.*
