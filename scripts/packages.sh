#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

# Inline helpers — silently no-op if parent already defined them
if [[ -z "${_HELPERS_LOADED:-}" ]]; then
  _HELPERS_LOADED=1
  info()    { echo "[INFO]    $*"; }
  success() { echo "[OK]      $*"; }
  error()   { echo "[ERROR]   $*" >&2; exit 1; }
fi

# OS detection — skip if parent already set OS_TYPE
if [[ -z "${OS_TYPE:-}" ]]; then
  case "$(uname -s)" in
    Darwin) OS_TYPE="darwin" ;;
    Linux)  OS_TYPE="linux"  ;;
    *)      error "Unsupported OS: $(uname -s)" ;;
  esac
fi

PACKAGES=(tmux fzf ripgrep bat jq direnv stow gcc curl git)

install_packages_macos() {
  if ! command -v brew &>/dev/null; then
    error "Homebrew not found. Install it from https://brew.sh first."
  fi
  info "Updating Homebrew..."
  brew update --quiet
  for pkg in "${PACKAGES[@]}" fd; do
    if brew list "$pkg" &>/dev/null; then
      info "$pkg already installed, skipping"
    else
      info "Installing $pkg..."
      brew install "$pkg"
    fi
  done
}

install_packages_linux() {
  info "Updating apt..."
  sudo apt-get update -qq
  # fd-find is the Debian package name for fd
  local apt_packages=("${PACKAGES[@]}" fd-find)
  local to_install=()
  for pkg in "${apt_packages[@]}"; do
    if dpkg -s "$pkg" &>/dev/null 2>&1; then
      info "$pkg already installed, skipping"
    else
      to_install+=("$pkg")
    fi
  done
  if [[ ${#to_install[@]} -gt 0 ]]; then
    sudo apt-get install -y "${to_install[@]}"
  fi
  # Create fd alias so 'fd' works on Debian/Ubuntu
  if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
    info "Linked fdfind -> ~/.local/bin/fd"
  fi
}

info "Installing base system packages..."

case "$OS_TYPE" in
  darwin) install_packages_macos ;;
  linux)  install_packages_linux ;;
esac

success "Base packages installed."
