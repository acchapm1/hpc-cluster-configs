#!/bin/bash
#
# Dotfiles Installer for HPC Environments
# Supports Rocky Linux 9.7 and similar RHEL-based systems
# Can be run remotely: curl -fsSL https://raw.githubusercontent.com/USER/REPO/main/install.sh | bash
#

set -euo pipefail

# Configuration
readonly DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/acchapm1/hpc-cluster-configs.git}"
readonly INSTALL_DIR="${HOME}/.dotfiles"

# Generate backup directory with timestamp
BACKUP_DIR="${HOME}/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"
readonly BACKUP_DIR

# List of dotfiles to install (files)
readonly DOTFILES=(
  ".bashrc"
  ".bash_profile"
  ".aliases"
  ".functions"
  ".vimrc"
  ".tmux.conf"
  ".git-completion.bash"
  ".git-prompt.sh"
)

# List of dot directories to install
readonly DOTDIRS=(
  ".vim"
  ".tmux"
)

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

# Logging functions
log_info() {
  printf "${GREEN}[INFO]${NC} %s\n" "$1"
}

log_warn() {
  printf "${YELLOW}[WARN]${NC} %s\n" "$1"
}

log_error() {
  printf "${RED}[ERROR]${NC} %s\n" "$1" >&2
}

# Check if running in a pipe (curl | bash)
is_piped() {
  [[ ! -t 0 ]]
}

# Create backup directory
create_backup_dir() {
  if [[ ! -d "${BACKUP_DIR}" ]]; then
    mkdir -p "${BACKUP_DIR}"
    log_info "Created backup directory: ${BACKUP_DIR}"
  fi
}

# Backup existing dotfile or directory
backup_item() {
  local item="$1"
  local target="${HOME}/${item}"

  if [[ -e "${target}" ]] || [[ -L "${target}" ]]; then
    log_info "Backing up ${item}"
    if [[ -d "${target}" ]]; then
      cp -rL "${target}" "${BACKUP_DIR}/"
    else
      cp -L "${target}" "${BACKUP_DIR}/"
    fi
  fi
}

# Install a single dotfile
install_dotfile() {
  local file="$1"
  local source="${INSTALL_DIR}/${file}"
  local target="${HOME}/${file}"

  if [[ -f "${source}" ]]; then
    backup_item "${file}"
    cp "${source}" "${target}"
    log_info "Installed ${file}"
  else
    log_warn "Source file not found: ${source}"
  fi
}

# Install a dot directory
install_dotdir() {
  local dir="$1"
  local source="${INSTALL_DIR}/${dir}"
  local target="${HOME}/${dir}"

  if [[ -d "${source}" ]]; then
    backup_item "${dir}"
    rm -rf "${target}"
    cp -r "${source}" "${target}"
    log_info "Installed ${dir}/"
  else
    log_warn "Source directory not found: ${source}"
  fi
}

# Clone or update the repository
fetch_dotfiles() {
  if [[ -d "${INSTALL_DIR}/.git" ]]; then
    log_info "Updating existing dotfiles repository"
    cd "${INSTALL_DIR}"
    git pull --quiet
  else
    log_info "Cloning dotfiles repository"
    rm -rf "${INSTALL_DIR}"
    git clone --quiet "${DOTFILES_REPO}" "${INSTALL_DIR}"
  fi
}

# Install vim plugins
install_vim_plugins() {
  log_info "Setting up Vim plugins"

  # Install vim-plug if not present
  if [[ ! -f "${HOME}/.vim/autoload/plug.vim" ]]; then
    log_info "Installing vim-plug"
    curl -fsSL --create-dirs -o "${HOME}/.vim/autoload/plug.vim" \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  fi

  # Install plugins headlessly
  if command -v vim &>/dev/null; then
    vim -u "${HOME}/.vimrc" -c 'PlugInstall --sync' -c 'qa' 2>/dev/null || \
      log_warn "Vim plugin installation may have issues (non-fatal)"
  fi
}

# Install tmux plugins
install_tmux_plugins() {
  log_info "Setting up Tmux plugins"

  # Install TPM if not present
  if [[ ! -d "${HOME}/.tmux/plugins/tpm" ]]; then
    log_info "Installing Tmux Plugin Manager (TPM)"
    git clone --quiet https://github.com/tmux-plugins/tpm \
      "${HOME}/.tmux/plugins/tpm"
  fi

  # Source tmux config if tmux is running
  if command -v tmux &>/dev/null && [[ -n "${TMUX:-}" ]]; then
    tmux source-file "${HOME}/.tmux.conf" 2>/dev/null || true
  fi
}

# Install glow binary to ~/.local/bin
install_glow() {
  local glow_source="${INSTALL_DIR}/glow"
  local glow_target_dir="${HOME}/.local/bin"
  local glow_target="${glow_target_dir}/glow"

  if [[ -f "${glow_source}" ]]; then
    # Create ~/.local/bin if it doesn't exist
    if [[ ! -d "${glow_target_dir}" ]]; then
      log_info "Creating ${glow_target_dir}"
      mkdir -p "${glow_target_dir}"
    fi

    # Backup existing glow if present
    if [[ -f "${glow_target}" ]]; then
      log_info "Backing up existing glow binary"
      cp "${glow_target}" "${BACKUP_DIR}/"
    fi

    # Copy glow binary
    cp "${glow_source}" "${glow_target}"
    chmod +x "${glow_target}"
    log_info "Installed glow to ${glow_target}"

    # Warn if ~/.local/bin is not in PATH
    if [[ ":${PATH}:" != *":${glow_target_dir}:"* ]]; then
      log_warn "${glow_target_dir} is not in your PATH"
      log_warn "Add 'export PATH=\"\${HOME}/.local/bin:\${PATH}\"' to your ~/.bashrc"
    fi
  else
    log_warn "glow binary not found in repository (non-fatal)"
  fi
}

# Main installation function
main() {
  log_info "Starting dotfiles installation"
  log_info "Backup location: ${BACKUP_DIR}"

  # Create backup directory
  create_backup_dir

  # If piped, we need to clone the repo first
  if is_piped; then
    if ! command -v git &>/dev/null; then
      log_error "Git is required but not installed"
      exit 1
    fi
    fetch_dotfiles
  else
    # Running from local directory
    INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
    log_info "Using local directory: ${INSTALL_DIR}"
  fi

  # Install dotfiles
  log_info "Installing dotfiles..."
  for file in "${DOTFILES[@]}"; do
    install_dotfile "${file}"
  done

  # Install dot directories
  log_info "Installing dot directories..."
  for dir in "${DOTDIRS[@]}"; do
    install_dotdir "${dir}"
  done

  # Setup plugins
  install_vim_plugins
  install_tmux_plugins

  # Install glow binary
  install_glow

  # Summary
  log_info "Installation complete!"
  log_info "Backups saved to: ${BACKUP_DIR}"
  log_info ""
  log_info "Installed:"
  log_info "  - Dotfiles in home directory"
  log_info "  - glow binary in ~/.local/bin/"
  log_info ""
  log_info "Next steps:"
  log_info "  1. Run 'source ~/.bashrc' to reload your shell"
  log_info "  2. Start tmux and press 'prefix + I' to install tmux plugins"
  log_info "  3. Open vim and run :PlugStatus to check plugin status"
}

# Run main function
main "$@"
