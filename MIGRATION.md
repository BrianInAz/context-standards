# Legacy Repository Migration Guide

## Overview
Migration from 8 separate AI agent repositories to unified `context-standards` architecture.

## Repositories to Archive
- [ ] `claude-standards`
- [ ] `gemini-standards` 
- [ ] `cursor-standards`
- [ ] `roo-standards`
- [ ] `copilot-standards`
- [ ] `windsurf-standards`
- [ ] `qwen-standards` 
- [ ] `deepseek-standards`

## Migration Steps

### Phase 1: Prepare Infrastructure ✅
- [x] Create feature branch `feature/legacy-repo-migration`
- [x] Update dotfiles `setup.sh` to use unified endpoint
- [x] Test global and project setup modes

### Phase 2: Deprecate Legacy Repos ✅
- [x] Add deprecation notices to all 8 repositories
- [x] Update any documentation references
- [x] Notify team of migration timeline

### Phase 3: Archive 🔄
- [ ] Archive all 8 legacy repositories
- [ ] Verify no broken links remain

## Test Results ✅

**Project Setup Test:** `/tmp/test-project`
```bash
cd /tmp/test-project && bash <(curl -s https://raw.githubusercontent.com/BrianInAz/context-standards/main/setup-ai-context.sh)
```
✅ Created AGENTS.md template  
✅ Created .claude/CLAUDE.md → ../AGENTS.md symlink  
✅ Created .gemini/GEMINI.md → ../AGENTS.md symlink  
✅ Created .roo/roo.md → ../AGENTS.md symlink  
✅ Created .cursorrules → AGENTS.md symlink  

**Global Setup Test:** `~/.bjzy`
```bash
cd ~ && bash <(curl -s https://raw.githubusercontent.com/BrianInAz/context-standards/main/setup-ai-context.sh)
```
✅ Cloned full context-standards repository to ~/.bjzy  
✅ Created ~/.claude → ~/.bjzy symlink  
✅ Created ~/.gemini → ~/.bjzy symlink  
✅ Created ~/.windsurf → ~/.bjzy symlink  
✅ Created ~/.bjzy/CLAUDE.md → AGENTS.md symlink  
✅ Created ~/.bjzy/GEMINI.md → AGENTS.md symlink  

**Migration Status:** Ready for Phase 3 (Archive)

## Updated Dotfiles Integration

**Before (multiple calls):**
```bash
# Multiple individual repo setups
claude-standards/setup.sh
gemini-standards/setup.sh
# ... 6 more repos
```

**After (single unified call):**
```bash
cd ~ && bash <(curl -s https://raw.githubusercontent.com/BrianInAz/context-standards/main/setup-ai-context.sh)
```

## Rollback Plan
If issues arise, legacy repositories can be unarchived and previous setup restored.

## Success Criteria
- [x] Unified AI context system working
- [ ] Dotfiles integration updated and tested
- [ ] All legacy repos safely archived
- [ ] Zero broken references
- [ ] Team successfully migrated
