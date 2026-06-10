# ===== Meisam personal Zsh config =====

# ---- asdf version manager ----
# Core asdf sourcing (shims + main script)
# Place this early-ish in .zshrc (before other tool inits, but after Oh My Zsh if using it)
. "$HOME/.asdf/asdf.sh"

# Optional but recommended: bash-style completions in Zsh
# (helps with asdf commands like asdf plugin add/update)
. "$HOME/.asdf/completions/asdf.bash"

# ---- zoxide ----
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"

# ---- fzf ----
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh