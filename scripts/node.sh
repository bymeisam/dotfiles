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

FNM_DIR="${FNM_DIR:-$HOME/.local/share/fnm}"

# ── Install fnm ──────────────────────────────────────────────────────────────

install_fnm() {
  if command -v fnm &>/dev/null; then
    info "fnm already installed ($(fnm --version)), skipping"
    return
  fi
  case "$OS_TYPE" in
    darwin)
      info "Installing fnm via Homebrew..."
      brew install fnm
      ;;
    linux)
      info "Installing fnm via install script..."
      curl -fsSL https://fnm.vercel.app/install | bash -s -- --install-dir "$HOME/.local/bin" --skip-shell
      export PATH="$HOME/.local/bin:$PATH"
      ;;
  esac
}

# ── Wire fnm into shell configs idempotently ─────────────────────────────────

configure_shell() {
  local marker="# fnm"
  local snippet
  case "$OS_TYPE" in
    darwin)
      snippet='eval "$(fnm env --use-on-cd --shell zsh)"'
      ;;
    linux)
      snippet='export PATH="$HOME/.local/bin:$PATH"
eval "$(fnm env --use-on-cd --shell zsh)"'
      ;;
  esac

  for rc in "$HOME/.zshrc" "$HOME/.bashrc"; do
    [[ -f "$rc" ]] || continue
    if grep -q "$marker" "$rc"; then
      info "fnm already configured in $rc, skipping"
    else
      printf '\n%s\n%s\n' "$marker" "$snippet" >> "$rc"
      info "Added fnm init to $rc"
    fi
  done
}

# ── Install Node LTS via fnm ─────────────────────────────────────────────────

install_node_lts() {
  # fnm needs its env loaded in this shell session
  if ! command -v fnm &>/dev/null; then
    export PATH="$HOME/.local/bin:$PATH"
  fi
  eval "$(fnm env --shell bash)" 2>/dev/null || true

  if fnm list | grep -q "lts-latest"; then
    info "Node LTS already installed via fnm, skipping"
  else
    info "Installing Node LTS..."
    fnm install --lts
  fi

  fnm default lts-latest
  eval "$(fnm env --shell bash)" 2>/dev/null || true
  success "Node $(node --version) active via fnm"
}

# ── Run ──────────────────────────────────────────────────────────────────────

info "Setting up fnm + Node LTS..."

install_fnm
configure_shell
install_node_lts

success "Node setup complete. Run 'source ~/.zshrc' or open a new terminal."
