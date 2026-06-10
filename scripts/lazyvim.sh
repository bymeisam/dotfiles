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

# ── Neovim ──────────────────────────────────────────────────────────────────

install_neovim_macos() {
  if brew list neovim &>/dev/null; then
    info "Neovim already installed, skipping"
  else
    info "Installing Neovim via Homebrew..."
    brew install neovim
  fi
}

install_neovim_linux() {
  if command -v nvim &>/dev/null; then
    info "Neovim already installed ($(nvim --version | head -1)), skipping"
    return
  fi
  local tmp
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT

  info "Fetching latest Neovim release..."
  local tag
  tag="$(curl -fsSL https://api.github.com/repos/neovim/neovim/releases/latest \
        | grep '"tag_name"' | head -1 | cut -d'"' -f4)"
  local url="https://github.com/neovim/neovim/releases/download/${tag}/nvim-linux-x86_64.tar.gz"

  info "Downloading Neovim ${tag}..."
  curl -fsSL "$url" -o "$tmp/nvim.tar.gz"
  tar -C "$tmp" -xzf "$tmp/nvim.tar.gz"

  sudo mkdir -p /opt/nvim
  sudo rsync -a --delete "$tmp/nvim-linux-x86_64/" /opt/nvim/
  sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
  success "Neovim ${tag} installed to /opt/nvim"
}

# ── lazygit ─────────────────────────────────────────────────────────────────

install_lazygit_macos() {
  if brew list lazygit &>/dev/null; then
    info "lazygit already installed, skipping"
  else
    brew install lazygit
  fi
}

install_lazygit_linux() {
  if command -v lazygit &>/dev/null; then
    info "lazygit already installed, skipping"
    return
  fi
  local tmp
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT

  info "Fetching latest lazygit release..."
  local tag
  tag="$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest \
        | grep '"tag_name"' | head -1 | cut -d'"' -f4)"
  local version="${tag#v}"
  local url="https://github.com/jesseduffield/lazygit/releases/download/${tag}/lazygit_${version}_Linux_x86_64.tar.gz"

  curl -fsSL "$url" -o "$tmp/lazygit.tar.gz"
  tar -C "$tmp" -xzf "$tmp/lazygit.tar.gz" lazygit
  sudo install -m 755 "$tmp/lazygit" /usr/local/bin/lazygit
  success "lazygit ${tag} installed"
}

# ── tree-sitter CLI ──────────────────────────────────────────────────────────

install_tree_sitter() {
  if command -v tree-sitter &>/dev/null; then
    info "tree-sitter CLI already installed, skipping"
    return
  fi
  if [[ "$OS_TYPE" == "darwin" ]]; then
    brew install tree-sitter
  else
    # Prefer npm when available; fall back to cargo
    if command -v npm &>/dev/null; then
      npm install -g tree-sitter-cli
    elif command -v cargo &>/dev/null; then
      cargo install tree-sitter-cli
    else
      info "tree-sitter CLI skipped — install npm or cargo first, or LazyVim will manage parsers itself"
    fi
  fi
}

# ── LazyVim starter ──────────────────────────────────────────────────────────

install_lazyvim() {
  local nvim_config="$HOME/.config/nvim"
  if [[ -d "$nvim_config" && -f "$nvim_config/lua/config/lazy.lua" ]]; then
    info "LazyVim starter already present at $nvim_config, skipping"
    return
  fi
  if [[ -d "$nvim_config" ]]; then
    info "Backing up existing Neovim config to ${nvim_config}.bak"
    mv "$nvim_config" "${nvim_config}.bak.$(date +%Y%m%d%H%M%S)"
  fi
  info "Cloning LazyVim starter..."
  git clone --depth 1 https://github.com/LazyVim/starter "$nvim_config"
  rm -rf "$nvim_config/.git"
  success "LazyVim starter installed to $nvim_config"
}

# ── Run ──────────────────────────────────────────────────────────────────────

info "Installing Neovim + LazyVim..."

case "$OS_TYPE" in
  darwin)
    install_neovim_macos
    install_lazygit_macos
    ;;
  linux)
    install_neovim_linux
    install_lazygit_linux
    ;;
esac

install_tree_sitter
install_lazyvim

success "Neovim + LazyVim setup complete."
