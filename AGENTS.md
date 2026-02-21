# AGENTS.md

Guidelines for AI coding agents working on this dotfiles repository.

## Project Overview

This repository contains personal configuration files (dotfiles) for a Unix/Linux development environment, including Vim, Bash, Tmux, and Opencode AI assistant configurations. The repository manages shell environment customization, editor settings, and terminal multiplexer configuration.

**Primary Languages:** Vimscript, Bash, Tmux configuration

## Build/Test Commands

This repository contains configuration files with no automated build system. Testing is done by:

- **Vim Config**: `vim -u ~/.vimrc -c 'echo "Config loaded successfully"' -c 'q'`
- **Tmux Config**: `tmux source-file ~/.tmux.conf` (reloads config in running session)
- **Bash Syntax**: `bash -n ~/.bashrc` (syntax check only)
- **Vim Syntax**: `vim -e -c 'source %' -c 'q' <file>`
- **ShellCheck**: `shellcheck ~/.bashrc ~/.bash_profile ~/.functions` (for bash scripts)

## Code Style Guidelines

### Vimscript

- **Indentation**: 2 spaces (no tabs)
- **Comments**: Use `"` for comments, align consecutive comments
- **Line Length**: 72 characters maximum
- **Mappings**: Use `<leader>` (space key) for custom commands
- **Naming**: snake_case for variables, UPPER_CASE for constants
- **Folding**: Use marker folding `{{{` and `}}}` for sections
- **Structure**: Group related settings, separate sections with blank lines

```vim
" Good example
set tabstop=2
set shiftwidth=2
set expandtab

" Enable syntax highlighting
syntax enable
filetype plugin indent on
```

### Bash Scripts

- **Shebang**: Always use `#!/bin/bash`
- **Indentation**: 2 spaces
- **Variables**: UPPER_CASE for environment/constants, snake_case for local
- **Quotes**: Always quote variables: `"${VAR}"`
- **Error Handling**: Use `set -euo pipefail` for strict mode in standalone scripts
- **Functions**: Use `snake_case()`, prefix with `builtin` when sourcing
- **Comments**: Use `#` with space after, explain complex logic

```bash
# Good example
my_function() {
  local var_name="${1}"
  if [[ -f "${var_name}" ]]; then
    builtin source "${var_name}"
  fi
}
```

### Tmux Configuration

- **Indentation**: 2 spaces
- **Key Bindings**: Group related bindings, use consistent prefixes
- **Comments**: Use `#` for comments
- **Naming**: kebab-case for custom options, descriptive names
- **Structure**: Group settings by category (general, keybindings, plugins, theme)

### General Conventions

- **File Naming**: Use dot prefix for hidden files (e.g., `.bashrc`)
- **Permissions**: Executable bits only on script files (644 for configs, 755 for scripts)
- **Organization**: Modular configuration using `source`/`source-file` directives
- **Backups**: Keep `.undo`, `.backup`, `.tmp` directories for vim state

## Project Structure

```
/                          # Root
├── .vim/                  # Vim configuration
│   ├── autoload/          # Plugin autoload scripts
│   ├── colors/            # Color schemes
│   ├── optional/          # Optional feature modules
│   ├── plugged/           # vim-plug plugins
│   ├── plugin/            # Plugin configurations
│   └── after/             # After-load scripts
├── .opencode/             # Opencode AI configuration
│   ├── commands/          # Custom slash commands
│   ├── skills/            # Skill modules
│   └── plugins/           # Plugin configurations
├── .tmux/                 # Tmux plugins (TPM)
├── .bashrc                # Bash shell configuration
├── .bash_profile          # Login shell configuration
├── .aliases               # Shell aliases
├── .functions             # Shell functions
└── .tmux.conf             # Tmux configuration
```

## Error Handling Patterns

### Bash
```bash
# Check if file exists before sourcing
if [[ -f ~/.custom_config ]]; then
  builtin source ~/.custom_config
fi

# Function with error handling
safe_mkcd() {
  if mkdir -p "$@"; then
    cd "${@:$#}" || return 1
  fi
}
```

### Vim
```vim
" Check if feature exists
if has("mouse")
  set mouse-=a
endif

" Conditional loading
if filereadable(expand("~/.vim/custom.vim"))
  source ~/.vim/custom.vim
endif
```

## Dependencies

- **Vim**: Version 8.0+ with `+eval` support
- **Tmux**: Version 3.0+ with TPM (Tmux Plugin Manager)
- **Bash**: Version 4.0+
- **Git**: For completion and prompt scripts
- **Optional**: `fzf`, `gum`, `shellcheck` for enhanced functionality

## Security Considerations

- Never commit sensitive data (passwords, API keys, private keys)
- Use restrictive permissions (600) for files containing personal settings
- Validate all external inputs in functions
- Review plugin sources before adding to vim-plug or TPM
