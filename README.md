# Dotfiles

My terminal setup. One command turns a new Mac (or Ubuntu/Debian box) into my usual environment: zsh + oh-my-zsh, starship prompt, tmux, tmuxinator, Neovim (LazyVim), git + delta, and modern CLI tools.

## New laptop setup

```bash
# 1. Xcode command line tools (macOS only — gives you git)
xcode-select --install

# 2. Clone to ~/.dotfiles (HTTPS — no SSH key yet on a fresh machine)
git clone https://github.com/bymeisam/dotfiles.git ~/.dotfiles

# 3. Run the installer
~/.dotfiles/install.sh              # or: ~/.dotfiles/install.sh --with-mise

# 4. Start a new shell
exec zsh
```

Then:

1. **Git identity** — check `name` / `email` in `~/.dotfiles/git/.gitconfig`.
2. **SSH key** — `ssh-keygen -t ed25519 -C "you@example.com"`, then `gh auth login` to upload it.
3. **Switch remotes to SSH** (so you can push):
   ```bash
   git -C ~/.dotfiles   remote set-url origin git@github.com:bymeisam/dotfiles.git
   git -C ~/.config/nvim remote set-url origin git@github.com:bymeisam/lazyvim.git
   ```
4. **Terminal font** — set it to `JetBrainsMono Nerd Font` (needed for `eza --icons` and starship glyphs).
5. **Node/Go/etc.** — install whatever version manager the team uses (see [Version managers](#version-managers)).

The installer is **idempotent**, so you can re-run it any time after pulling changes.

## What the installer does

| Step | macOS | Linux (apt) |
|---|---|---|
| Package manager | Installs Homebrew if missing, puts it on `PATH` | `apt-get update` |
| Shell | zsh as default shell, oh-my-zsh, `zsh-autosuggestions`, `zsh-syntax-highlighting` | same |
| CLI tools | `tmux neovim fzf ripgrep fd bat eza zoxide jq gh starship git-delta lazygit direnv httpie tldr htop stow tmuxinator` + JetBrainsMono Nerd Font | same set, from apt or upstream releases (x86_64 and arm64); `fdfind`/`batcat` are linked as `fd`/`bat` |
| Neovim deps | `tree-sitter-cli` (builds parsers) and `node` (Copilot, mason's npm LSPs). fzf, ripgrep, fd and lazygit come from the row above | latest Neovim release (apt's is too old), `tree-sitter`, NodeSource LTS `node`, `build-essential`, `unzip` |
| Symlinks | `stow`s every package below into `$HOME`. Real files in the way are renamed to `*.bak` | same |
| SSH | Copies `ssh/.ssh_config` → `~/.ssh/config` **only if it doesn't exist** | same |
| Neovim | Clones [bymeisam/lazyvim](https://github.com/bymeisam/lazyvim) → `~/.config/nvim` (a non-git `~/.config/nvim` is backed up first), then installs plugins at the versions in `lazy-lock.json` | same |
| Local overrides | Creates an empty `~/.zshrc.local` | same |
| `--with-mise` | Also installs [mise](https://mise.jdx.dev) | same |

## Layout

Each top-level folder is a [GNU Stow](https://www.gnu.org/software/stow/) package that mirrors `$HOME`. Stow ignores `README*` files in the package root.

```
dotfiles/
├── install.sh
├── zsh/         .zshrc                              → ~/.zshrc
├── tmux/        tmux.conf                           → ~/.tmux.conf          (linked by install.sh, not stow; docs: tmux/README.md)
├── git/         .gitconfig, .gitignore_global       → ~/
├── starship/    .config/starship.toml               → ~/.config/starship.toml
├── tmuxinator/  .config/tmuxinator/sample.yml       → ~/.config/tmuxinator/  (docs: tmuxinator/README.md)
└── ssh/         .ssh_config                         → copied (not linked) to ~/.ssh/config
```

Neovim config lives in its own repo: [bymeisam/lazyvim](https://github.com/bymeisam/lazyvim).

Because files are **symlinked**, editing `~/.zshrc` edits the repo. Commit and push from `~/.dotfiles`.

## Highlights

### zsh (`zsh/.zshrc`)
- oh-my-zsh plugins: `git`, `zsh-autosuggestions`, `zsh-syntax-highlighting`, `fzf`, `direnv`
- [starship](https://starship.rs) prompt (`directory git_branch ❯`). Falls back to a plain prompt if starship isn't installed
- `zoxide` (`z <dir>`), with fzf backed by `fd`
- Aliases: `ls/ll/lt` → eza, `cat` → bat, `vi/vim` → nvim, `g`, `gs`, `gd`, `gl` (lazygit), `reload`
- Sources `~/.zshrc.local` last for per-machine, work-only or secret config

### tmux (`tmux/tmux.conf`)
Prefix `Ctrl+Space`, vim-style `h/j/k/l` navigation and `H/J/K/L` resizing, `v`/`s` or `\`/`-` splits, vi copy mode, mouse, true color. Full keymap: [tmux/README.md](tmux/README.md).

### git (`git/.gitconfig`)
`delta` side-by-side diffs, `pull.rebase`, `push.autoSetupRemote`, `rebase.autoStash`, `diff3` conflicts, and aliases `st co br lg last undo pushup`.

### tmuxinator
Only a template is tracked. To make a workspace: `tmuxinator copy sample myproject && tmuxinator edit myproject`. Real workspaces stay local (see [tmuxinator/README.md](tmuxinator/README.md)).

## Version managers

No version manager is installed by default, because every team picks its own. A baseline `node` is installed so Neovim tooling works. A version manager puts its own node first on `PATH`, so projects still get the team's version. `.zshrc` activates whichever one it finds:

1. **mise** if installed (`install.sh --with-mise`). It also reads `.nvmrc`, `.node-version` and `.tool-versions`, so it usually works with whatever a team uses.
2. Otherwise **fnm** if installed.
3. For anything else (nvm, volta, asdf…), put its init line in `~/.zshrc.local`.

## Machine-local config

`~/.zshrc.local` is sourced at the end of `.zshrc` and is **not** tracked. Use it for work aliases, tokens, and per-laptop `PATH` entries. This repo is public, so never commit secrets.

## Updating

```bash
cd ~/.dotfiles && git pull && ./install.sh
```

To capture a config from your current machine, move it into the matching package folder (keeping its path relative to `$HOME`), then run `./install.sh` or `stow --no-folding --restow -t ~ <pkg>`.

## Requirements

- macOS (Apple Silicon or Intel) or Debian/Ubuntu
- tmux ≥ 2.6, a true-color terminal (Ghostty, WezTerm, iTerm2…) and a Nerd Font
