#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_DIR

# ── Shared helpers ────────────────────────────────────────────────────────────
export _HELPERS_LOADED=1
info()    { echo "[INFO]    $*"; }
success() { echo "[OK]      $*"; }
error()   { echo "[ERROR]   $*" >&2; exit 1; }

# Export so sourced scripts see them
export -f info success error

# ── OS detection (done once) ──────────────────────────────────────────────────
case "$(uname -s)" in
  Darwin) export OS_TYPE="darwin" ;;
  Linux)  export OS_TYPE="linux"  ;;
  *)      error "Unsupported OS: $(uname -s)" ;;
esac

info "Detected OS: $OS_TYPE"
info "Dotfiles directory: $DOTFILES_DIR"
echo ""

# ── Run each module in order ──────────────────────────────────────────────────
scripts=(
  packages
  prompt
  node
  lazyvim
  dotfiles
)

for script in "${scripts[@]}"; do
  echo "──────────────────────────────────────────────"
  info "Running: scripts/${script}.sh"
  echo "──────────────────────────────────────────────"
  # shellcheck source=/dev/null
  source "$DOTFILES_DIR/scripts/${script}.sh"
  echo ""
done

echo "=============================================="
success "All done! Open a new terminal to apply changes."
echo "=============================================="
