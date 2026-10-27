# Dotfiles

My terminal setup. On a new Mac (or Ubuntu/Debian box), one script installs and configures the shell, prompt, tmux, Neovim (LazyVim), git and the CLI tools I use every day.

**Start here →** [New laptop setup](#new-laptop-setup) · [What you get](#what-you-get) · [What's not included](#whats-not-included) · [Platform notes](#platform-notes)

---

## New laptop setup

### 1. Run the installer

```bash
# macOS only: command line tools (gives you git). Wait for the popup to finish.
xcode-select --install

# clone over HTTPS (no SSH key yet on a fresh machine)
git clone https://github.com/bymeisam/dotfiles.git ~/.dotfiles

~/.dotfiles/install.sh          # add --with-mise to also install mise
exec zsh
```

It takes a few minutes and is safe to re-run. If it stops after the Xcode popup, run it again.

### 2. Finish by hand

| # | Step | How |
|---|---|---|
| 1 | Git identity | Check `name` / `email` in `~/.dotfiles/git/.gitconfig` |
| 2 | SSH key + GitHub | `ssh-keygen -t ed25519 -C "you@example.com"` then `gh auth login` |
| 3 | Switch repos to SSH so you can push | `git -C ~/.dotfiles remote set-url origin git@github.com:bymeisam/dotfiles.git`<br>`git -C ~/.config/nvim remote set-url origin git@github.com:bymeisam/lazyvim.git` |
| 4 | Terminal font | Install a terminal (e.g. Ghostty) and set its font to **JetBrainsMono Nerd Font** |
| 5 | Open `nvim` once | Mason downloads the language servers (TS, ESLint, Go, …) in the background |
| 6 | Language runtimes | Install the team's version manager, plus Go if needed (see [Version managers](#version-managers)) |
| 7 | Machine-local stuff | Work aliases, tokens and extra `PATH` entries go in `~/.zshrc.local` |

---

## What you get

### Installed

| Area | macOS (Homebrew) | Linux (apt + upstream releases, x86_64/arm64) |
|---|---|---|
| Package manager | Homebrew (installed if missing, added to `PATH`) | apt |
| Shell | zsh as default, oh-my-zsh, `zsh-autosuggestions`, `zsh-syntax-highlighting`, starship | same |
| Editor | Neovim, **LazyVim** (your config from [bymeisam/lazyvim](https://github.com/bymeisam/lazyvim), plugins pinned by `lazy-lock.json`), `tree-sitter-cli`, `node` | latest Neovim release (apt's is too old), `tree-sitter`, NodeSource LTS `node`, `build-essential`, `unzip` |
| Search & files | `fzf` `ripgrep` `fd` `bat` `eza` `zoxide` | same (`fdfind`/`batcat` linked as `fd`/`bat`) |
| Git | `git-delta` `lazygit` `gh` | same (gh: install manually) |
| Terminal | `tmux` `tmuxinator` | same |
| Misc | `jq` `direnv` `httpie` `tldr` `htop` `stow` | same |
| Font | JetBrainsMono Nerd Font | — (install manually) |
| Optional | `mise` with `--with-mise` | same |

### Configured

| Config | Repo file | Lives at | How |
|---|---|---|---|
| zsh | `zsh/.zshrc` | `~/.zshrc` | stow symlink |
| Prompt | `starship/.config/starship.toml` | `~/.config/starship.toml` | stow symlink |
| tmux | `tmux/tmux.conf` | `~/.tmux.conf` | symlink by `install.sh` |
| git | `git/.gitconfig`, `git/.gitignore_global` | `~/` | stow symlink |
| tmuxinator | `tmuxinator/.config/tmuxinator/sample.yml` | `~/.config/tmuxinator/` | stow symlink |
| SSH | `ssh/.ssh_config` | `~/.ssh/config` | copied once, if missing |
| Neovim | separate repo [bymeisam/lazyvim](https://github.com/bymeisam/lazyvim) | `~/.config/nvim` | git clone |
| Local overrides | — | `~/.zshrc.local` | created empty, not tracked |

Real files that would be replaced are renamed to `*.bak` first.

### Highlights

- **zsh**: starship prompt (`directory git_branch ❯`), grey type-ahead suggestions, syntax highlighting, `Ctrl+R`/`Ctrl+T` fzf search, `z <dir>` jumping. Aliases: `ls/ll/lt` → eza, `cat` → bat, `vi/vim` → nvim, `g`, `gs`, `gd`, `gl` (lazygit), `reload`.
- **tmux**: prefix `Ctrl+Space`, `h/j/k/l` to move between panes, `H/J/K/L` to resize, `v`/`s` (or `\`/`-`) to split, vi copy mode, mouse, true color. Full keymap: [tmux/README.md](tmux/README.md).
- **git**: side-by-side `delta` diffs, `pull.rebase`, `push.autoSetupRemote`, `rebase.autoStash`, `diff3` conflicts. Aliases: `st co br lg last undo pushup`.
- **tmuxinator**: a template only. `tmuxinator copy sample myproject && tmuxinator edit myproject`. See [tmuxinator/README.md](tmuxinator/README.md).
- **LazyVim**: fzf/telescope/snacks pickers, Copilot + Copilot Chat, TypeScript, Go, Tailwind, Terraform, YAML/JSON/Markdown, ESLint + Prettier, DAP debugging, neotest, harpoon, leap. Configured in the lazyvim repo, not here.

---

## What's not included

Install or set these up by hand:

| Missing | Notes |
|---|---|
| Terminal app + its config | Ghostty / WezTerm / iTerm2. On my Mac, Ghostty uses JetBrainsMono Nerd Font 14, `adjust-cell-height = 4`, padding 10 |
| Language runtimes | No version manager by default (team's choice), no Go, Python or Rust. Only a baseline `node` for Neovim |
| GUI apps | Browser, Docker Desktop, Raycast, Slack, … |
| macOS settings | Key repeat, Finder, Dock, trackpad (no `defaults write` script) |
| Secrets & identity | SSH keys, GitHub auth, tokens, real git email (repo has a placeholder) |
| Work-specific config | tmuxinator workspaces, work aliases → keep in `~/.config/tmuxinator/` and `~/.zshrc.local` |
| AI tools | Claude Code / Codex / opencode and their configs |
| Linux extras | `gh` and the Nerd Font aren't installed on Linux |

---

## Version managers

No version manager is installed by default, because every team picks its own. A baseline `node` is installed so Neovim tooling works. Any version manager puts its own node first on `PATH`, so projects still get the team's version. `.zshrc` activates whichever one it finds:

1. **mise** if installed (`install.sh --with-mise`). It also reads `.nvmrc`, `.node-version` and `.tool-versions`.
2. Otherwise **fnm** if installed.
3. For anything else (nvm, volta, asdf…), put its init line in `~/.zshrc.local`.

## How it works

The `zsh`, `git`, `tmuxinator` and `starship` folders are [GNU Stow](https://www.gnu.org/software/stow/) packages. Each one mirrors `$HOME` and is symlinked with `stow --no-folding`. `tmux/tmux.conf` stays visible (no leading dot) and is linked by `install.sh`. `ssh/` is copied once. Stow ignores the `README*` files in each package.

Because configs are **symlinks**, editing `~/.zshrc` edits the repo. Commit from `~/.dotfiles`.

## Updating

```bash
cd ~/.dotfiles && git pull && ./install.sh
```

To add a new config, put it in a package folder at its path relative to `$HOME` (e.g. `ghostty/.config/ghostty/config`), add the package to `STOW_PACKAGES` in `install.sh`, and re-run the installer.

## Platform notes

### All platforms

- **You need a terminal app.** The installer doesn't install one. Use **Ghostty** or **WezTerm** (iTerm2 and Windows Terminal also work). It needs true color support.
- **Set the terminal font to `JetBrainsMono Nerd Font`.** Without a Nerd Font, `eza --icons`, starship and LazyVim show boxes instead of icons.
- Not run end-to-end on a clean machine yet. Expect a hiccup on the first real run.

### macOS (Apple Silicon or Intel) — main target

- Fully supported. The setup comes from my working Mac.
- The Nerd Font **is installed** via Homebrew (`font-jetbrains-mono-nerd-font`). You still have to select it in the terminal.
- Install the terminal yourself: `brew install --cask ghostty` (or `wezterm`).
- The Xcode command line tools popup must finish before the installer can continue. Re-run it afterwards.

### Linux — Debian/Ubuntu only (x86_64 or arm64)

- **Only apt-based distros.** Fedora, Arch, etc. will fail at the first `apt-get`.
- **The Nerd Font and `gh` are not installed.** Get the font from [nerdfonts.com](https://www.nerdfonts.com/font-downloads) into `~/.local/share/fonts`, then run `fc-cache -f`.
- `.zshrc` sets `LANG=en_AU.UTF-8`. If you see locale warnings, run `sudo locale-gen en_AU.UTF-8`.
- On older Ubuntu (22.04), apt's `fzf` and `bat` are fairly old. Neovim, eza, delta, lazygit and tree-sitter come from upstream releases, so they're current.
- Needs `sudo`, and `chsh` asks for your password. `httpie` comes from pip and `tmuxinator` from `gem`.

### Windows — WSL2 only

- Native Windows isn't supported: the bash installer, zsh, tmux and stow are Unix-only.
- Install **WSL2 + Ubuntu**, then follow the Linux steps inside it.
- Install the Nerd Font **on Windows** (not inside WSL) and set it in your terminal: Windows Terminal or WezTerm. Ghostty doesn't run on Windows.
- Keep the repo and your projects in the Linux filesystem (`~/`), not `/mnt/c/...`. It's much faster and symlinks behave.
- Copying from tmux to the Windows clipboard depends on the terminal. Windows Terminal and WezTerm support it.
- Windows apps (VS Code, browsers, Docker Desktop) are outside these dotfiles.
