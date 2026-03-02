# AGENTS.md

This file guides AI coding agents working on this HPC dotfiles repository.

## Project Overview

This is a **shell/dotfiles configuration repository** for HPC environments (Rocky Linux 9.7/RHEL-based). It manages shell environments, Vim, and Tmux configurations.

- **Primary Language:** Bash/shell scripting
- **Platform:** HPC clusters
- **Package Manager:** None (vim-plug for Vim, TPM for Tmux)
- **Task Runner:** Just (`just` command)

## Commands

### Task Automation (Just)

```bash
# List all available recipes
just

# Full installation (equivalent to install.sh)
just install

# Install individual components
just dotfiles       # Install dotfiles only
just dirs           # Install dot directories (.vim/, .tmux/)
just vim-plugins    # Setup Vim plugins
just tmux-plugins   # Setup Tmux plugins
just binaries       # Install glow, just, loadkeys.sh

# Backup existing dotfiles before changes
just backup-dotfiles

# Sync changes from home directory back to repo
just sync-from-home

# Git workflow
just git-status
just git-diff
just git-add
just git-commit "message"
just git-push
just git-update "message"  # Sync + commit + push
```

### Direct Script Execution

```bash
# Run installer locally
./install.sh

# Run via curl (remote installation)
curl -fsSL https://raw.githubusercontent.com/acchapm1/hpc-cluster-configs/main/install.sh | bash
```

## Code Style Guidelines

### Shell Scripts (Bash)

- **Shebang:** Use `#!/bin/bash` or `#!/usr/bin/env bash`
- **Strict Mode:** Always use `set -euo pipefail` at the start
- **Indentation:** 2 spaces (no tabs)
- **Variables:**
  - Use `readonly` for constants: `readonly VAR="value"`
  - Use UPPER_CASE for environment/readonly variables
  - Use lower_case for local variables
  - Always quote variables: `"${var}"`
- **Functions:**
  - Define with `name() {` (no `function` keyword)
  - Use local variables: `local var="value"`
  - Return only exit codes (0-255), not strings
- **Error Handling:**
  - Use `|| true` for commands that may fail non-fatally
  - Check command existence: `command -v cmd &>/dev/null`
  - Provide meaningful error messages to stderr
- **Output:**
  - Use logging functions: `log_info`, `log_warn`, `log_error`
  - Include color codes: `${GREEN}[INFO]${NC}`
  - Redirect errors to stderr: `>&2`

### Vim Configuration

- **Indentation:** 2 spaces (no tabs), `set shiftwidth=2`
- **Comments:** Use `"` for single-line, `" {{{` / `" }}}` for folding
- **Leader Key:** Space (`let mapleader=' '`) for normal mode mappings
- **Plugin Management:** Use vim-plug (`Plug 'user/repo'`)
- **Mappings:** Use `nmap` for normal mode, `imap` for insert mode
- **Conditionals:** Use `if has("feature")` for feature detection
- **Folding:** Use marker-based folding for sections

### Tmux Configuration

- **Indentation:** 2 spaces
- **Comments:** Use `#` prefix
- **Key Bindings:** Use `-n` for root table, `-T prefix` for prefix table
- **Style:** Use tmux formatting syntax: `#{variable}`

### Justfile

- **Indentation:** 4 spaces for shebang recipes, 2 for just syntax
- **Naming:** Use kebab-case for recipe names
- **Variables:** Define at top with `:=`
- **Recipes:** Group related recipes with comments
- **Shebang Recipes:** Use `#!/usr/bin/env bash` for complex logic

## File Structure

```
.
├── Justfile              # Task automation
├── install.sh            # Main installation script
├── loadkeys.sh           # SSH key utility
├── glow, just            # Vendored binaries
├── .bashrc               # Shell environment
├── .bash_profile         # Login shell settings
├── .aliases              # Command shortcuts
├── .functions            # Shell functions
├── .vimrc                # Vim configuration
├── .vim/                 # Vim plugins/configs
├── .tmux.conf            # Tmux configuration
└── README.md             # User documentation
```

## HPC Environment Considerations

- Paths should use `${HOME}` not `~` in scripts
- Check for module system availability
- Avoid dependencies not available on compute nodes
- Support both interactive and piped (`curl | bash`) execution
- Backup existing configs before overwriting
- Use `~/.local/bin` for user-installed binaries
- Test with ` Rocky Linux 9.7` or similar RHEL-based systems

## Testing

This repository has no automated test suite. Test manually by:

1. Running `just install` in a clean environment
2. Verifying files are copied correctly
3. Sourcing shell configs: `source ~/.bashrc`
4. Testing Vim: `vim -c 'PlugStatus'`
5. Testing Tmux: `tmux source-file ~/.tmux.conf`

## Git Workflow

```bash
# Making changes
just sync-from-home    # Copy from home to repo
just git-status        # Review changes
just git-diff          # See detailed diff
just git-update "msg"  # Commit and push
```

## Security Notes

- Never commit secrets, SSH keys, or tokens
- Use `curl -fsSL` for secure downloads
- Validate file existence before operations
- Always backup before overwriting user files
