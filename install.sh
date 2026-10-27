#!/usr/bin/env bash
# Bootstrap a new machine. Safe to re-run.
#
#   git clone https://github.com/bymeisam/dotfiles.git ~/.dotfiles
#   ~/.dotfiles/install.sh [--with-mise]
set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
OS="$(uname -s)"
WITH_MISE=0

for arg in "$@"; do
  case "$arg" in
    --with-mise) WITH_MISE=1 ;;
    -h|--help)
      echo "usage: install.sh [--with-mise]"
      echo "  --with-mise   also install mise (node/go/... version manager)"
      exit 0
      ;;
    *) echo "unknown option: $arg" >&2; exit 1 ;;
  esac
done

# stow packages: each folder mirrors $HOME (README files are ignored by stow)
STOW_PACKAGES=(zsh git tmuxinator starship)
NVIM_REPO="https://github.com/bymeisam/lazyvim.git"

echo ""
echo "==> dotfiles install"
echo "    os: $OS"
echo "    dir: $DOTFILES"
echo ""

# ── helpers ───────────────────────────────────────────────────────────────────
info()    { echo "  [·] $1"; }
success() { echo "  [✓] $1"; }
warn()    { echo "  [!] $1"; }
error()   { echo "  [✗] $1" >&2; exit 1; }

install_pkg() {
  if [ "$OS" = "Darwin" ]; then
    brew install "$@"
  elif [ "$OS" = "Linux" ]; then
    sudo apt-get install -y "$@"
  else
    error "Unsupported OS: $OS"
  fi
}

# move aside real files that would block stow (existing symlinks are left alone)
backup_conflicts() {
  local pkg="$1" rel target
  while IFS= read -r rel; do
    target="$HOME/${rel#./}"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
      info "Backing up $target -> $target.bak"
      mv "$target" "$target.bak"
    fi
  done < <(cd "$DOTFILES/$pkg" && find . -type f ! -name 'README*' ! -name '.DS_Store')
}

if [ "$DOTFILES" != "$HOME/.dotfiles" ]; then
  warn "Repo is at $DOTFILES (expected ~/.dotfiles) — symlinks will point here, so don't move or delete it."
fi

# ── package manager ───────────────────────────────────────────────────────────
if [ "$OS" = "Darwin" ]; then
  if ! xcode-select -p &>/dev/null; then
    info "Installing Xcode Command Line Tools (finish the popup, then re-run this script)..."
    xcode-select --install
    exit 0
  fi

  if ! command -v brew &>/dev/null; then
    info "Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    success "Homebrew already installed"
  fi
  # make brew usable for the rest of this script (Apple Silicon vs Intel)
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
elif [ "$OS" = "Linux" ]; then
  info "Updating apt..."
  sudo apt-get update -qq
  install_pkg git curl wget
fi

# ── zsh ───────────────────────────────────────────────────────────────────────
if ! command -v zsh &>/dev/null; then
  info "Installing zsh..."
  install_pkg zsh
else
  success "zsh already installed"
fi

# set zsh as default shell (macOS already defaults to /bin/zsh)
if [ "$(basename "$SHELL")" != "zsh" ]; then
  info "Setting zsh as default shell..."
  chsh -s "$(command -v zsh)" || warn "chsh failed — run: chsh -s $(command -v zsh)"
fi

# ── oh-my-zsh ─────────────────────────────────────────────────────────────────
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  info "Installing oh-my-zsh..."
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  success "oh-my-zsh already installed"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# zsh-autosuggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  info "Installing zsh-autosuggestions..."
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
  success "zsh-autosuggestions already installed"
fi

# zsh-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  info "Installing zsh-syntax-highlighting..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
  success "zsh-syntax-highlighting already installed"
fi

# ── cli tools ─────────────────────────────────────────────────────────────────
info "Installing CLI tools..."

if [ "$OS" = "Darwin" ]; then
  brew install \
    tmux neovim fzf ripgrep fd bat eza zoxide jq gh starship \
    git-delta lazygit direnv httpie tlrc htop stow tmuxinator
  # LazyVim: tree-sitter builds parsers (nvim-treesitter main branch);
  # node runs Copilot + mason's npm-based LSPs (project versions still come
  # from the team's version manager, which takes precedence on PATH)
  brew install tree-sitter-cli node
  # eza --icons and starship need a Nerd Font (set it in your terminal)
  brew install --cask font-jetbrains-mono-nerd-font

elif [ "$OS" = "Linux" ]; then
  case "$(uname -m)" in
    aarch64|arm64) ARCH=arm64 ;;
    *)             ARCH=x86_64 ;;
  esac

  # build-essential: C compiler for treesitter parsers; unzip: used by mason
  sudo apt-get install -y tmux fzf ripgrep fd-find bat jq direnv tldr htop stow ruby \
    build-essential unzip

  # apt's neovim is too old for LazyVim — use the official release
  if ! command -v nvim &>/dev/null; then
    info "Installing neovim..."
    curl -Lo /tmp/nvim.tar.gz "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${ARCH}.tar.gz"
    sudo rm -rf /opt/nvim && sudo mkdir -p /opt/nvim
    sudo tar xzf /tmp/nvim.tar.gz -C /opt/nvim --strip-components=1
    sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
  fi

  if ! command -v tree-sitter &>/dev/null; then
    info "Installing tree-sitter CLI..."
    [ "$ARCH" = arm64 ] && TS_ARCH=arm64 || TS_ARCH=x64
    curl -Lo /tmp/tree-sitter.gz "https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-${TS_ARCH}.gz"
    gunzip -f /tmp/tree-sitter.gz
    sudo install /tmp/tree-sitter /usr/local/bin/tree-sitter
  fi

  if ! command -v node &>/dev/null; then
    info "Installing node (LTS, for nvim tooling)..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt-get install -y nodejs
  fi

  # Debian/Ubuntu ship these under different names — the aliases expect fd/bat
  mkdir -p "$HOME/.local/bin"
  command -v fdfind &>/dev/null && ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
  command -v batcat &>/dev/null && ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"

  if ! command -v eza &>/dev/null; then
    info "Installing eza..."
    [ "$ARCH" = arm64 ] && EZA_ARCH=aarch64 || EZA_ARCH=x86_64
    curl -Lo /tmp/eza.tar.gz "https://github.com/eza-community/eza/releases/latest/download/eza_${EZA_ARCH}-unknown-linux-gnu.tar.gz"
    tar xzf /tmp/eza.tar.gz -C /tmp
    sudo install /tmp/eza /usr/local/bin/eza
  fi

  if ! command -v zoxide &>/dev/null; then
    info "Installing zoxide..."
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
  fi

  if ! command -v starship &>/dev/null; then
    info "Installing starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y
  fi

  if ! command -v delta &>/dev/null; then
    info "Installing delta..."
    # release .debs are versioned (git-delta_<ver>_<arch>.deb), so look up the tag
    DELTA_VERSION=$(curl -s "https://api.github.com/repos/dandavison/delta/releases/latest" | grep '"tag_name"' | sed -E 's/.*"v*([^"]+)".*/\1/')
    [ "$ARCH" = arm64 ] && DEB_ARCH=arm64 || DEB_ARCH=amd64
    curl -Lo /tmp/delta.deb "https://github.com/dandavison/delta/releases/latest/download/git-delta_${DELTA_VERSION}_${DEB_ARCH}.deb"
    sudo dpkg -i /tmp/delta.deb
  fi

  if ! command -v lazygit &>/dev/null; then
    info "Installing lazygit..."
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep '"tag_name"' | sed -E 's/.*"v*([^"]+)".*/\1/')
    curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_${ARCH}.tar.gz"
    tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
    sudo install /tmp/lazygit /usr/local/bin
  fi

  if ! command -v http &>/dev/null; then
    info "Installing httpie..."
    pip3 install httpie --break-system-packages 2>/dev/null || true
  fi

  if ! command -v tmuxinator &>/dev/null; then
    info "Installing tmuxinator..."
    sudo gem install tmuxinator
  fi
fi

success "CLI tools installed"

# ── version manager (opt-in) ──────────────────────────────────────────────────
if [ "$WITH_MISE" = 1 ]; then
  if ! command -v mise &>/dev/null; then
    info "Installing mise..."
    if [ "$OS" = "Darwin" ]; then brew install mise; else curl -fsSL https://mise.run | sh; fi
  else
    success "mise already installed"
  fi
fi

# ── stow symlinks ─────────────────────────────────────────────────────────────
info "Stowing dotfiles..."
cd "$DOTFILES"

for pkg in "${STOW_PACKAGES[@]}"; do
  backup_conflicts "$pkg"
  # --no-folding: link files, never whole dirs (so ~/.config stays a real dir)
  stow --no-folding --restow --target="$HOME" "$pkg"
done

# tmux.conf is kept visible in the repo, so it's linked by hand rather than stowed
if [ -e "$HOME/.tmux.conf" ] && [ ! -L "$HOME/.tmux.conf" ]; then
  info "Backing up $HOME/.tmux.conf -> $HOME/.tmux.conf.bak"
  mv "$HOME/.tmux.conf" "$HOME/.tmux.conf.bak"
fi
ln -sfn "$DOTFILES/tmux/tmux.conf" "$HOME/.tmux.conf"

# ssh config is copied, not linked — it usually gains machine-specific hosts
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
if [ ! -f "$HOME/.ssh/config" ]; then
  cp "$DOTFILES/ssh/.ssh_config" "$HOME/.ssh/config"
  chmod 600 "$HOME/.ssh/config"
fi

success "Dotfiles symlinked"

# ── LazyVim (config lives in its own repo, based on the LazyVim starter) ──────
if [ ! -d "$HOME/.config/nvim" ]; then
  info "Cloning LazyVim config..."
  git clone "$NVIM_REPO" "$HOME/.config/nvim"
elif [ ! -d "$HOME/.config/nvim/.git" ]; then
  info "Backing up ~/.config/nvim -> ~/.config/nvim.bak"
  mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak"
  git clone "$NVIM_REPO" "$HOME/.config/nvim"
else
  success "nvim config already present"
fi

# first headless run bootstraps lazy.nvim, which installs LazyVim + all plugins
# at the versions pinned in lazy-lock.json, so first launch is ready
info "Installing LazyVim and plugins (this can take a minute)..."
nvim --headless "+Lazy! restore" +qa || warn "plugin install failed — open nvim and run :Lazy restore"

# ── local overrides ───────────────────────────────────────────────────────────
if [ ! -f "$HOME/.zshrc.local" ]; then
  echo "# machine-local zsh config (not tracked in dotfiles)" > "$HOME/.zshrc.local"
fi

# ── done ──────────────────────────────────────────────────────────────────────
echo ""
echo "==> all done! run: exec zsh"
echo ""
echo "    next steps:"
echo "    1. update email in ~/.gitconfig"
echo "    2. generate ssh key: ssh-keygen -t ed25519 -C 'your@email.com'"
echo "       then add it to GitHub: gh auth login"
echo "    3. switch nvim remote to ssh: git -C ~/.config/nvim remote set-url origin git@github.com:bymeisam/lazyvim.git"
echo "    4. set your terminal font to 'JetBrainsMono Nerd Font'"
echo "    5. install a version manager if needed (re-run with --with-mise, or use the team's choice)"
echo ""
