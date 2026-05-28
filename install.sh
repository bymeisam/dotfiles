#!/usr/bin/env bash
set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
OS="$(uname -s)"

echo ""
echo "==> dotfiles install"
echo "    os: $OS"
echo "    dir: $DOTFILES"
echo ""

# ── helpers ───────────────────────────────────────────────────────────────────
info()    { echo "  [·] $1"; }
success() { echo "  [✓] $1"; }
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

# ── move dotfiles to ~/.dotfiles if not already there ────────────────────────
if [ "$DOTFILES" != "$HOME/.dotfiles" ]; then
  info "Moving dotfiles to ~/.dotfiles..."
  cp -r "$DOTFILES" "$HOME/.dotfiles"
  DOTFILES="$HOME/.dotfiles"
  success "Dotfiles moved to ~/.dotfiles"
fi

# ── package manager ───────────────────────────────────────────────────────────
if [ "$OS" = "Darwin" ]; then
  if ! command -v brew &>/dev/null; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    success "Homebrew already installed"
  fi
elif [ "$OS" = "Linux" ]; then
  info "Updating apt..."
  sudo apt-get update -qq
fi

# ── zsh ───────────────────────────────────────────────────────────────────────
if ! command -v zsh &>/dev/null; then
  info "Installing zsh..."
  install_pkg zsh
else
  success "zsh already installed"
fi

# set zsh as default shell
if [ "$SHELL" != "$(which zsh)" ]; then
  info "Setting zsh as default shell..."
  chsh -s "$(which zsh)"
fi

# ── oh-my-zsh ─────────────────────────────────────────────────────────────────
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  info "Installing oh-my-zsh..."
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
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

# powerlevel10k
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
  info "Installing powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
else
  success "powerlevel10k already installed"
fi

# ── cli tools ─────────────────────────────────────────────────────────────────
info "Installing CLI tools..."

if [ "$OS" = "Darwin" ]; then
  brew install \
    tmux neovim fzf ripgrep fd bat eza zoxide jq \
    git-delta lazygit fnm direnv httpie tldr htop stow tmuxinator

elif [ "$OS" = "Linux" ]; then
  sudo apt-get install -y tmux neovim fzf ripgrep fd-find bat jq direnv tldr htop stow

  if ! command -v eza &>/dev/null; then
    info "Installing eza..."
    wget -qO /tmp/eza.deb "https://github.com/eza-community/eza/releases/latest/download/eza_amd64.deb" \
      && sudo dpkg -i /tmp/eza.deb
  fi

  if ! command -v zoxide &>/dev/null; then
    info "Installing zoxide..."
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
  fi

  if ! command -v delta &>/dev/null; then
    info "Installing delta..."
    wget -qO /tmp/delta.deb "https://github.com/dandavison/delta/releases/latest/download/git-delta_amd64.deb" \
      && sudo dpkg -i /tmp/delta.deb
  fi

  if ! command -v lazygit &>/dev/null; then
    info "Installing lazygit..."
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep '"tag_name"' | sed -E 's/.*"v*([^"]+)".*/\1/')
    curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
    sudo install /tmp/lazygit /usr/local/bin
  fi

  if ! command -v fnm &>/dev/null; then
    info "Installing fnm..."
    curl -fsSL https://fnm.vercel.app/install | bash
  fi

  if ! command -v http &>/dev/null; then
    info "Installing httpie..."
    pip3 install httpie --break-system-packages 2>/dev/null || true
  fi

  if ! command -v tmuxinator &>/dev/null; then
    info "Installing tmuxinator..."
    gem install tmuxinator
  fi
fi

success "CLI tools installed"

# ── stow symlinks ─────────────────────────────────────────────────────────────
info "Stowing dotfiles..."
cd "$DOTFILES"

# back up and remove any existing files that would block stow
for f in ~/.zshrc ~/.tmux.conf ~/.gitconfig ~/.gitignore_global; do
  if [ -f "$f" ] && [ ! -L "$f" ]; then
    info "Backing up $f -> $f.bak"
    mv "$f" "$f.bak"
  fi
done

stow --target="$HOME" zsh
stow --target="$HOME" tmux
stow --target="$HOME" git

# ssh config
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
if [ ! -f "$HOME/.ssh/config" ]; then
  cp "$DOTFILES/ssh/.ssh_config" "$HOME/.ssh/config"
  chmod 600 "$HOME/.ssh/config"
fi

# tmuxinator
mkdir -p "$HOME/.tmuxinator"
[ ! -f "$HOME/.tmuxinator/dev.yml" ] && cp "$DOTFILES/tmuxinator/dev.yml" "$HOME/.tmuxinator/dev.yml"

success "Dotfiles symlinked"

# ── git global ignore ─────────────────────────────────────────────────────────
git config --global core.excludesfile "$HOME/.gitignore_global"

# ── reload shell ──────────────────────────────────────────────────────────────
info "Reloading shell config..."
source "$HOME/.zshrc" 2>/dev/null || true

# ── done ──────────────────────────────────────────────────────────────────────
echo ""
echo "==> all done! run: exec zsh"
echo ""
echo "    next steps:"
echo "    1. update email in ~/.gitconfig"
echo "    2. generate ssh key: ssh-keygen -t ed25519 -C 'your@email.com'"
echo "    3. install LazyVim: https://www.lazyvim.org"
echo "    4. install node: fnm install --lts"
echo "    5. run 'p10k configure' to set up your prompt"
echo ""
