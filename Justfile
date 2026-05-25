# Justfile for HPC Dotfiles
# Dotfiles management for HPC environments

# Default recipe - shows available recipes
default:
    @just --list

# Configuration
DOTFILES_REPO := env("DOTFILES_REPO", "https://github.com/acchapm1/hpc-cluster-configs.git")
INSTALL_DIR := env("INSTALL_DIR", "~/.dotfiles")
BACKUP_DIR := env("BACKUP_DIR", "~/.dotfiles_backup/" + `date +%Y%m%d_%H%M%S`)

# List of dotfiles to install
DOTFILES_LIST := ".bashrc .bash_profile .aliases .functions .vimrc .tmux.conf .git-completion.bash"
DOTDIRS_LIST := ".vim"

# Full installation - equivalent to running install.sh
install: backup-dotfiles install-dotfiles install-dirs vim-plugins tmux-plugins binaries
    @echo "✓ Installation complete!"
    @echo "  Backups saved to: {{BACKUP_DIR}}"
    @echo ""
    @echo "Next steps:"
    @echo "  1. Run 'source ~/.bashrc' to reload your shell"
    @echo "  2. Start tmux and press 'prefix + I' to install tmux plugins"
    @echo "  3. Open vim and run :PlugStatus to check plugin status"

# Clone or update dotfiles repository
fetch:
    #!/usr/bin/env bash
    if [[ -d "{{INSTALL_DIR}}/.git" ]]; then
        echo "[INFO] Updating existing dotfiles repository"
        cd "{{INSTALL_DIR}}" && git pull --quiet
    else
        echo "[INFO] Cloning dotfiles repository"
        rm -rf "{{INSTALL_DIR}}"
        git clone --quiet "{{DOTFILES_REPO}}" "{{INSTALL_DIR}}"
    fi

# Create backup directory and backup existing dotfiles
backup-dotfiles:
    #!/usr/bin/env bash
    mkdir -p "{{BACKUP_DIR}}"
    echo "[INFO] Created backup directory: {{BACKUP_DIR}}"
    for item in {{DOTFILES_LIST}} {{DOTDIRS_LIST}}; do
        target="$HOME/$item"
        if [[ -e "$target" ]] || [[ -L "$target" ]]; then
            echo "[INFO] Backing up $item"
            if [[ -d "$target" ]]; then
                cp -rL "$target" "{{BACKUP_DIR}}/"
            else
                cp -L "$target" "{{BACKUP_DIR}}/"
            fi
        fi
    done

# Install all dotfiles
install-dotfiles:
    #!/usr/bin/env bash
    echo "[INFO] Installing dotfiles..."
    for file in {{DOTFILES_LIST}}; do
        source="{{INSTALL_DIR}}/$file"
        target="$HOME/$file"
        if [[ -f "$source" ]]; then
            cp "$source" "$target"
            echo "[INFO] Installed $file"
        else
            echo "[WARN] Source file not found: $source"
        fi
    done

# Install all dot directories
install-dirs:
    #!/usr/bin/env bash
    echo "[INFO] Installing dot directories..."
    for dir in {{DOTDIRS_LIST}}; do
        source="{{INSTALL_DIR}}/$dir"
        target="$HOME/$dir"
        if [[ -d "$source" ]]; then
            rm -rf "$target"
            cp -r "$source" "$target"
            echo "[INFO] Installed $dir/"
        else
            echo "[WARN] Source directory not found: $source"
        fi
    done

# Install vim plugins and vim-plug
vim-plugins:
    #!/usr/bin/env bash
    echo "[INFO] Setting up Vim plugins"
    if [[ ! -f "$HOME/.vim/autoload/plug.vim" ]]; then
        echo "[INFO] Installing vim-plug"
        curl -fsSL --create-dirs -o "$HOME/.vim/autoload/plug.vim" \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    fi
    if command -v vim &>/dev/null; then
        vim -u "$HOME/.vimrc" -c 'PlugInstall --sync' -c 'qa' 2>/dev/null || \
            echo "[WARN] Vim plugin installation may have issues (non-fatal)"
    fi

# Install tmux plugins and TPM
tmux-plugins:
    #!/usr/bin/env bash
    echo "[INFO] Setting up Tmux plugins"
    if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
        echo "[INFO] Installing Tmux Plugin Manager (TPM)"
        git clone --quiet https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    fi
    if command -v tmux &>/dev/null && [[ -n "${TMUX:-}" ]]; then
        tmux source-file "$HOME/.tmux.conf" 2>/dev/null || true
    fi

# Install all binaries (glow, just, loadkeys.sh)
binaries: ensure-local-bin install-glow install-just install-loadkeys
    @echo "[INFO] All binaries installed"

# Ensure ~/.local/bin exists
ensure-local-bin:
    #!/usr/bin/env bash
    mkdir -p "$HOME/.local/bin"
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        echo "[WARN] ~/.local/bin is not in your PATH"
        echo "[WARN] Add 'export PATH=\"\$HOME/.local/bin:\$PATH\"' to your ~/.bashrc"
    fi

# Install glow binary
install-glow: ensure-local-bin
    #!/usr/bin/env bash
    source="{{INSTALL_DIR}}/glow"
    target="$HOME/.local/bin/glow"
    if [[ -f "$source" ]]; then
        if [[ -f "$target" ]]; then
            echo "[INFO] Backing up existing glow"
            cp "$target" "{{BACKUP_DIR}}/"
        fi
        cp "$source" "$target"
        chmod +x "$target"
        echo "[INFO] Installed glow to $target"
    else
        echo "[WARN] glow binary not found in repository (non-fatal)"
    fi

# Install just binary
install-just: ensure-local-bin
    #!/usr/bin/env bash
    source="{{INSTALL_DIR}}/just"
    target="$HOME/.local/bin/just"
    if [[ -f "$source" ]]; then
        if [[ -f "$target" ]]; then
            echo "[INFO] Backing up existing just"
            cp "$target" "{{BACKUP_DIR}}/"
        fi
        cp "$source" "$target"
        chmod +x "$target"
        echo "[INFO] Installed just to $target"
    else
        echo "[WARN] just binary not found in repository (non-fatal)"
    fi

# Install loadkeys.sh script
install-loadkeys: ensure-local-bin
    #!/usr/bin/env bash
    source="{{INSTALL_DIR}}/loadkeys.sh"
    target="$HOME/.local/bin/loadkeys.sh"
    if [[ -f "$source" ]]; then
        if [[ -f "$target" ]]; then
            echo "[INFO] Backing up existing loadkeys.sh"
            cp "$target" "{{BACKUP_DIR}}/"
        fi
        cp "$source" "$target"
        chmod +x "$target"
        echo "[INFO] Installed loadkeys.sh to $target"
    else
        echo "[WARN] loadkeys.sh not found in repository (non-fatal)"
    fi

# Install individual components (convenience aliases)
dotfiles: install-dotfiles
    @echo "✓ Dotfiles installed"

dirs: install-dirs
    @echo "✓ Directories installed"

# Clean up backup directory
clean-backups:
    #!/usr/bin/env bash
    echo "[INFO] Removing backup directory: {{BACKUP_DIR}}"
    rm -rf "{{BACKUP_DIR}}"

# Show current configuration
config:
    @echo "Configuration:"
    @echo "  DOTFILES_REPO: {{DOTFILES_REPO}}"
    @echo "  INSTALL_DIR:   {{INSTALL_DIR}}"
    @echo "  BACKUP_DIR:    {{BACKUP_DIR}}"
    @echo ""
    @echo "Dotfiles: {{DOTFILES_LIST}}"
    @echo "Dotdirs:  {{DOTDIRS_LIST}}"

# ====================
# Git Management Recipes
# ====================

# Show git status
git-status:
    @echo "[INFO] Git status:"
    @git status

# Show git diff
git-diff:
    @echo "[INFO] Git diff:"
    @git diff

# Add all changes to git staging
git-add:
    @echo "[INFO] Adding all changes to staging..."
    @git add .
    @echo "✓ Changes staged. Run 'just git-commit MSG=\"your message\"' to commit"

# Commit changes (requires MSG parameter)
git-commit MSG:
    @echo "[INFO] Committing changes: {{MSG}}"
    @git commit -m "{{MSG}}"
    @echo "✓ Changes committed. Run 'just git-push' to push to remote"

# Push changes to remote
git-push:
    @echo "[INFO] Pushing to remote..."
    @git push
    @echo "✓ Changes pushed to remote"

# Pull latest changes from remote
git-pull:
    @echo "[INFO] Pulling latest changes from remote..."
    @git pull
    @echo "✓ Latest changes pulled"

# Sync with remote (pull then push)
git-sync:
    @echo "[INFO] Syncing with remote..."
    @git pull
    @git push
    @echo "✓ Sync complete"

# Sync dotfiles from home directory back to repo (reverse of install)
sync-from-home:
    #!/usr/bin/env bash
    echo "[INFO] Syncing dotfiles from home directory to repo..."
    repo_dir="$(cd "$(dirname "$0")" && pwd)"
    for file in {{DOTFILES_LIST}}; do
        home_file="$HOME/$file"
        repo_file="$repo_dir/$file"
        if [[ -f "$home_file" ]]; then
            cp "$home_file" "$repo_file"
            echo "[INFO] Synced $file from home to repo"
        else
            echo "[WARN] $file not found in home directory"
        fi
    done
    for dir in {{DOTDIRS_LIST}}; do
        home_dir="$HOME/$dir"
        repo_dir_path="$repo_dir/$dir"
        if [[ -d "$home_dir" ]]; then
            rm -rf "$repo_dir_path"
            cp -r "$home_dir" "$repo_dir_path"
            echo "[INFO] Synced $dir/ from home to repo"
        else
            echo "[WARN] $dir/ not found in home directory"
        fi
    done
    echo "✓ Dotfiles synced from home to repo"
    echo "[INFO] Review changes with 'just git-status' and 'just git-diff'"

# Full workflow: sync from home, commit, and push (requires MSG parameter)
git-update MSG:
    @just sync-from-home
    @just git-add
    @just git-commit "{{MSG}}"
    @just git-push
    @echo "✓ Full update complete: changes synced, committed, and pushed"
