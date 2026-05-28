# ── oh-my-zsh ────────────────────────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""  # using custom prompt below
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  fzf
  direnv
)
source $ZSH/oh-my-zsh.sh

# ── prompt ────────────────────────────────────────────────────────────────────
git_branch() {
  git branch --show-current 2>/dev/null | sed 's/\(.*\)/ (\1)/'
}
PROMPT='-> %1~ $(git_branch) '

# ── path ──────────────────────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$HOME/bin:/usr/local/bin:$PATH"

# ── fnm (node version manager) ───────────────────────────────────────────────
export FNM_PATH="$HOME/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "$(fnm env --use-on-cd)"
fi

# ── zoxide (smart cd) ─────────────────────────────────────────────────────────
eval "$(zoxide init zsh)"

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
