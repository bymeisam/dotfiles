# ── homebrew ──────────────────────────────────────────────────────────────────
# fresh Apple Silicon Macs don't have /opt/homebrew/bin on PATH
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# ── oh-my-zsh ────────────────────────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""  # prompt comes from starship below
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  fzf
  direnv
)
source $ZSH/oh-my-zsh.sh

# ── path ──────────────────────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$HOME/bin:/usr/local/bin:$PATH"
[ -d /Applications/Docker.app ] && export PATH="/Applications/Docker.app/Contents/Resources/bin:$PATH"
[ -d "$HOME/.opencode/bin" ] && export PATH="$HOME/.opencode/bin:$PATH"

# ── prompt ────────────────────────────────────────────────────────────────────
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
else
  git_branch() {
    git branch --show-current 2>/dev/null | sed 's/\(.*\)/ (\1)/'
  }
  setopt PROMPT_SUBST
  PROMPT='-> %1~ $(git_branch) '
fi

# ── version managers (optional) ──────────────────────────────────────────────
# Not installed by default — use whatever the team uses. Each one activates
# only if present. mise also reads .nvmrc / .node-version / .tool-versions.
if command -v mise &>/dev/null; then
  eval "$(mise activate zsh)"
elif command -v fnm &>/dev/null; then
  eval "$(fnm env --use-on-cd)"
fi

# ── zoxide (smart cd) ─────────────────────────────────────────────────────────
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"

# ── fzf ───────────────────────────────────────────────────────────────────────
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# ── aliases ───────────────────────────────────────────────────────────────────
# ls
alias ls='eza --icons'
alias ll='eza -lah --icons --git'
alias lt='eza --tree --icons --level=2'

# cat
alias cat='bat --style=plain'

# git
alias g='git'
alias gs='git status'
alias gd='git diff'
alias gl='lazygit'

# navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ~='cd ~'

# misc
alias vi='nvim'
alias vim='nvim'
alias reload='source ~/.zshrc'

# ── environment ───────────────────────────────────────────────────────────────
export EDITOR='nvim'
export VISUAL='nvim'
export LANG='en_AU.UTF-8'

# ── machine-local overrides (not in git) ─────────────────────────────────────
# work aliases, secrets, per-laptop PATH tweaks go in ~/.zshrc.local
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
