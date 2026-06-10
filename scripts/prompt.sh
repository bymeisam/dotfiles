#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

if [[ -z "${_HELPERS_LOADED:-}" ]]; then
  _HELPERS_LOADED=1
  info()    { echo "[INFO]    $*"; }
  success() { echo "[OK]      $*"; }
  error()   { echo "[ERROR]   $*" >&2; exit 1; }
fi

if [[ -z "${OS_TYPE:-}" ]]; then
  case "$(uname -s)" in
    Darwin) OS_TYPE="darwin" ;;
    Linux)  OS_TYPE="linux"  ;;
    *)      error "Unsupported OS: $(uname -s)" ;;
  esac
fi

# ── zsh ──────────────────────────────────────────────────────────────────────

install_zsh() {
  if command -v zsh &>/dev/null; then
    info "zsh already installed, skipping"
    return
  fi
  case "$OS_TYPE" in
    darwin) brew install zsh ;;
    linux)  sudo apt-get install -y zsh ;;
  esac
}

set_default_shell() {
  if [[ "$SHELL" == *zsh ]]; then
    info "zsh is already the default shell, skipping"
    return
  fi
  local zsh_path
  zsh_path="$(command -v zsh)"
  # Add to /etc/shells if not already present (required for chsh on Linux)
  if ! grep -qxF "$zsh_path" /etc/shells; then
    echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
  fi
  info "Setting zsh as default shell..."
  chsh -s "$zsh_path"
}

# ── Oh My Zsh ────────────────────────────────────────────────────────────────

install_ohmyzsh() {
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    info "Oh My Zsh already installed, skipping"
    return
  fi
  info "Installing Oh My Zsh..."
  RUNZSH=no CHSH=no \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

# ── Plugins & theme ──────────────────────────────────────────────────────────

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

clone_if_missing() {
  local repo="$1" dest="$2"
  if [[ -d "$dest" ]]; then
    info "$(basename "$dest") already present, skipping"
  else
    info "Cloning $(basename "$dest")..."
    git clone --depth 1 "$repo" "$dest"
  fi
}

install_omz_plugins() {
  mkdir -p "$ZSH_CUSTOM/plugins" "$ZSH_CUSTOM/themes"

  clone_if_missing \
    https://github.com/zsh-users/zsh-autosuggestions \
    "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

  clone_if_missing \
    https://github.com/zsh-users/zsh-syntax-highlighting \
    "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

  clone_if_missing \
    https://github.com/romkatv/powerlevel10k.git \
    "$ZSH_CUSTOM/themes/powerlevel10k"
}

# ── zoxide ───────────────────────────────────────────────────────────────────

install_zoxide() {
  if command -v zoxide &>/dev/null; then
    info "zoxide already installed, skipping"
    return
  fi
  case "$OS_TYPE" in
    darwin) brew install zoxide ;;
    linux)
      # Official installer works on all Linux distros
      curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
      ;;
  esac
}

# ── eza ──────────────────────────────────────────────────────────────────────

install_eza() {
  if command -v eza &>/dev/null; then
    info "eza already installed, skipping"
    return
  fi
  case "$OS_TYPE" in
    darwin) brew install eza ;;
    linux)
      sudo apt-get install -y gpg
      sudo mkdir -p /etc/apt/keyrings
      wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
        | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
      echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
        | sudo tee /etc/apt/sources.list.d/gierens.list
      sudo apt-get update -qq
      sudo apt-get install -y eza
      ;;
  esac
}

# ── Run ──────────────────────────────────────────────────────────────────────

info "Setting up shell prompt (zsh + Oh My Zsh + p10k + plugins)..."

install_zsh
install_ohmyzsh
install_omz_plugins
install_zoxide
install_eza
set_default_shell

success "Prompt setup complete. Open a new terminal to start using zsh + Oh My Zsh."
