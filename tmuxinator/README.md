# tmuxinator

Workspace automation for tmux: one command opens a project's windows, panes and dev processes.

This package only ships a template, [`sample.yml`](.config/tmuxinator/sample.yml). Your real workspaces are often work-specific, so they stay local in `~/.config/tmuxinator/` and are not tracked.

## Install

`install.sh` stows this package, which links `sample.yml` into `~/.config/tmuxinator/`. To link it on its own:

```bash
cd ~/.dotfiles && stow --no-folding -t ~ tmuxinator
```

## Create a workspace from the template

```bash
tmuxinator copy sample myproject   # new local file: ~/.config/tmuxinator/myproject.yml
tmuxinator edit myproject          # set root, windows, commands
tmuxinator start myproject
```

Because stow runs with `--no-folding`, `~/.config/tmuxinator/` is a real directory. New workspaces land there, not in this repo.

## Config cheatsheet

```yaml
name: myproject
root: ~/projects/myproject      # starting dir for every pane
pre_window: nvm use             # optional: runs in each pane first

windows:
  - window-name:
      layout: tiled             # tiled | even-horizontal | even-vertical | main-vertical | main-horizontal
      panes:
        - single-command
        - pane-name:            # named pane, several commands
            - cd somewhere
            - npm run dev
        - ""                    # empty shell
```

## Commands

| Command | Action |
|---|---|
| `tmuxinator ls` | List workspaces |
| `tmuxinator start <name> [-n session]` | Start (optionally under another session name) |
| `tmuxinator stop <name>` | Stop |
| `tmuxinator edit <name>` | Edit |
| `tmuxinator copy <from> <to>` | Copy |
| `tmuxinator debug <name>` | Show the tmux commands it would run |

## Troubleshooting

- Commands that use aliases (e.g. a `cd`-to-project alias) need that alias in `~/.zshrc.local`. Using `root:` is usually simpler.
- Cycle pane layouts after launch with `Ctrl+Space` then `Space`.
