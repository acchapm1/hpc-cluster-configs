# Usage Guide

This guide explains how to use the `install.sh` script to set up your HPC environment.

## Quick Start

Run this command on any Rocky Linux 9.7 (or similar) HPC node:

```bash
curl -fsSL https://raw.githubusercontent.com/acchapm1/hpc-cluster-configs/main/install.sh | bash
```

## What It Does

The install script performs the following actions:

### 1. Backs Up Existing Configurations
- Creates a timestamped backup directory: `~/.dotfiles_backup/YYYYMMDD_HHMMSS/`
- Saves copies of any existing dotfiles before overwriting them

### 2. Installs Dotfiles
Copies these configuration files to your home directory:
- `.bashrc` - Shell configuration with aliases and environment
- `.bash_profile` - Login shell settings
- `.aliases` - Command shortcuts
- `.functions` - Shell functions
- `.vimrc` - Vim editor configuration
- `.tmux.conf` - Tmux terminal multiplexer settings
- `.git-completion.bash` - Git tab completion
- `.git-prompt.sh` - Git status in prompt

### 3. Installs Dot Directories
- `.vim/` - Vim plugins and configuration
- `.tmux/` - Tmux plugins and themes

### 4. Sets Up Vim
- Installs vim-plug (plugin manager)
- Downloads and installs all Vim plugins defined in `.vimrc`

### 5. Sets Up Tmux
- Installs TPM (Tmux Plugin Manager)
- Configures Catppuccin theme and various plugins

### 6. Installs Glow
- Copies the `glow` binary to `~/.local/bin/`
- Creates `~/.local/bin/` directory if needed
- Warns if the directory is not in your PATH

### 7. Clones lci-scripts
- Downloads https://github.com/ncsa/lci-scripts.git to `~/lci-scripts/`

## After Installation

1. **Reload your shell:**
   ```bash
   source ~/.bashrc
   ```

2. **Install Tmux plugins:**
   - Start tmux: `tmux`
   - Press `Ctrl+Space` (prefix) then `I` (capital i)
   - Wait for plugins to install

3. **Verify Vim plugins:**
   ```bash
   vim
   :PlugStatus
   ```

## Security Note

For security, you can download and inspect the script before running:

```bash
curl -fsSL -o install.sh https://raw.githubusercontent.com/acchapm1/hpc-cluster-configs/main/install.sh
cat install.sh  # Review the script
bash install.sh
```

## Troubleshooting

**Issue:** `glow` command not found
**Solution:** Add to your PATH:
```bash
echo 'export PATH="${HOME}/.local/bin:${PATH}"' >> ~/.bashrc
source ~/.bashrc
```

**Issue:** Permission denied when running install.sh
**Solution:** Make it executable:
```bash
chmod +x install.sh
./install.sh
```

**Issue:** Git not found
**Solution:** The script requires git. Load it via your cluster's module system:
```bash
module load git
```

## Custom Repository

To use a different repository:

```bash
DOTFILES_REPO=https://github.com/YOUR_USERNAME/YOUR_REPO.git curl -fsSL https://raw.githubusercontent.com/acchapm1/hpc-cluster-configs/main/install.sh | bash
```
