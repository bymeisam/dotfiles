#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

if [[ -z "${_HELPERS_LOADED:-}" ]]; then
  _HELPERS_LOADED=1
  info()    { echo "[INFO]    $*"; }
  success() { echo "[OK]      $*"; }
  error()   { echo "[ERROR]   $*" >&2; exit 1; }
fi

# ── Ensure stow is available ─────────────────────────────────────────────────

if ! command -v stow &>/dev/null; then
  error "stow not found. Run scripts/packages.sh first."
fi

# ── Back up a path if it exists and is not already a symlink ────────────────

backup_if_exists() {
  local target="$1"
  if [[ -e "$target" && ! -L "$target" ]]; then
    local backup="${target}.bak.$(date +%Y%m%d%H%M%S)"
    info "Backing up $target -> $backup"
    mv "$target" "$backup"
  fi
}

# ── Stow a package ───────────────────────────────────────────────────────────

stow_package() {
  local pkg="$1"
  local pkg_dir="$DOTFILES_DIR/$pkg"

  if [[ ! -d "$pkg_dir" ]]; then
    info "Package '$pkg' not found at $pkg_dir, skipping"
    return
  fi

  # Pre-emptively back up any non-symlink files that stow would conflict with
  while IFS= read -r -d '' file; do
    local rel="${file#"$pkg_dir"/}"
    backup_if_exists "$HOME/$rel"
  done < <(find "$pkg_dir" -type f -print0)

  info "Stowing $pkg..."
  stow --dir="$DOTFILES_DIR" --target="$HOME" --restow "$pkg"
  success "$pkg stowed"
}

# ── Run ──────────────────────────────────────────────────────────────────────

info "Linking dotfiles via stow (target: $HOME)..."

for pkg in zsh tmux git; do
  stow_package "$pkg"
done

success "Dotfiles linked. Files backed up with .bak.<timestamp> if they existed."
