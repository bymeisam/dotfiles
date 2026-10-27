# CLAUDE.md

Personal dotfiles, cloned to `~/.dotfiles` and installed with `./install.sh`. Goal: a new laptop gets the full setup in one run. Public repo: never commit secrets, tokens, or work-internal details.

## Structure

- Each folder in `STOW_PACKAGES` (`zsh git tmuxinator starship`) is a GNU Stow package that mirrors `$HOME`. Files are symlinked with `stow --no-folding`.
- To add a new config, place it at its `$HOME`-relative path inside a package (e.g. `ghostty/.config/ghostty/config`). For a new package, also add it to `STOW_PACKAGES` in `install.sh`.
- `README*` files at a package root are ignored by stow, so docs can live next to the config.
- Exceptions, not stowed: `tmux/tmux.conf` is kept visible (not dot-prefixed) on purpose, and `install.sh` symlinks it to `~/.tmux.conf`. `ssh/` is copied once to `~/.ssh/config`.
- Neovim config is a separate repo (`bymeisam/lazyvim`). `install.sh` clones it. Don't add nvim files here.

## Conventions

- `install.sh` must stay idempotent and safe to re-run. Guard every install with `command -v` or a directory check, and back up real files before stowing over them.
- Support both macOS (brew) and Debian/Ubuntu (apt) whenever you add a tool.
- `.zshrc` must not error if a tool is missing. Guard each `eval "$(tool init)"` with `command -v`.
- Machine-specific or work-only config goes in `~/.zshrc.local` (untracked), not `.zshrc`. The same goes for tmuxinator workspaces: only the generic `sample.yml` is tracked.
- Version managers (mise/fnm/…) are opt-in, not installed by default. The team's choice wins.
- Leave `git/.gitconfig` identity alone unless asked.
- Keep the existing section-header comment style (`# ── name ───…`).

## Checking changes

```bash
bash -n install.sh && zsh -n zsh/.zshrc
# preview symlinks into a throwaway HOME
T=$(mktemp -d) && for p in zsh git tmuxinator starship; do stow --no-folding -t "$T" "$p"; done && find "$T"
```

Update `README.md` when packages, tools, or install steps change.
