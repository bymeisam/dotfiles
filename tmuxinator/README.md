# tmuxinator Configuration

Workspace automation for tmux sessions. Quickly launch predefined development environments with multiple windows and panes.

## Workspaces

### myworkspace

A frontend development workspace with three windows optimized for UI development workflow.

#### Layout

**Window 1: terminals** (tiled layout)
- **Pane 1 (test)**: Runs `uife` then `npm run test` - continuous test runner
- **Pane 2 (design-system)**: Runs `uife` then `npm run tcv` - design system/component viewer
- **Pane 3 (storybook)**: Runs `uife` then `npm run storybook` - Storybook dev server
- **Pane 4**: General purpose terminal for ad-hoc commands

**Window 2: editor**
- Neovim opened in the frontend directory (`uife` command)

**Window 3: projects**
- Neovim opened in the `~/Projects` directory for quick file browsing

#### Usage

```bash
# Start the workspace
tmuxinator start myworkspace

# Start with a custom name
tmuxinator start myworkspace -n my-session-name

# Stop the workspace
tmuxinator stop myworkspace
```

## Installation

```bash
# Install tmuxinator (requires Ruby)
gem install tmuxinator

# Create config directory if it doesn't exist
mkdir -p ~/.config/tmuxinator

# Create symlink to workspace config
ln -sf $(pwd)/myworkspace.yml ~/.config/tmuxinator/myworkspace.yml
```

## Customization

### Creating Your Own Workspace

1. Copy `myworkspace.yml` to a new file:
   ```bash
   cp myworkspace.yml myproject.yml
   ```

2. Edit the workspace name and commands:
   ```yaml
   name: myproject
   windows:
     - window-name:
         panes:
           - command1
           - command2
   ```

3. Link it to tmuxinator config:
   ```bash
   ln -sf $(pwd)/myproject.yml ~/.config/tmuxinator/myproject.yml
   ```

### Workspace Configuration Options

```yaml
name: workspace-name          # Name of the workspace
root: ~/path/to/project      # Optional: Starting directory

windows:
  - window-name:              # Name appears in tmux status bar
      layout: tiled           # Layout: tiled, even-horizontal, even-vertical, main-vertical
      panes:
        - command             # Single command
        - pane-name:          # Named pane with multiple commands
            - cd somewhere
            - run command
```

### Available Layouts

- `tiled`: Automatically tiles all panes
- `even-horizontal`: Equal horizontal splits
- `even-vertical`: Equal vertical splits
- `main-vertical`: Large left pane, stacked right panes
- `main-horizontal`: Large top pane, side-by-side bottom panes

## Commands

### Basic Commands

```bash
# List all workspaces
tmuxinator list
# or
tmuxinator ls

# Start a workspace
tmuxinator start <workspace-name>

# Stop a workspace
tmuxinator stop <workspace-name>

# Edit a workspace
tmuxinator edit <workspace-name>

# Delete a workspace
tmuxinator delete <workspace-name>

# Copy a workspace
tmuxinator copy <existing> <new>

# Debug workspace (see what commands will run)
tmuxinator debug <workspace-name>
```

### Aliases

Add to your `.zshrc` or `.bashrc`:

```bash
alias mux="tmuxinator"
alias muxs="tmuxinator start"
alias muxl="tmuxinator list"
```

## Requirements

- tmux (must be installed and working)
- tmuxinator (`gem install tmuxinator`)
- Ruby (for tmuxinator)

### Optional Dependencies

For the `myworkspace` configuration:
- `uife` alias/command that navigates to your frontend project directory
- Node.js and npm (for `npm run` commands)

## Tips

1. **Quick Start**: Create a shell alias to start your default workspace:
   ```bash
   alias work="tmuxinator start myworkspace"
   ```

2. **Multiple Instances**: Start the same workspace with different names:
   ```bash
   tmuxinator start myworkspace -n feature-branch
   tmuxinator start myworkspace -n bugfix
   ```

3. **Pre/Post Commands**: Add startup and cleanup commands:
   ```yaml
   pre_window: echo "Starting window"
   post: echo "Workspace ready!"
   ```

4. **Conditional Commands**: Chain commands with `&&` for dependencies:
   ```yaml
   - cd project && npm install && npm start
   ```

## Troubleshooting

### Commands not running
- Ensure the `uife` command/alias is defined in your shell configuration
- Check that the command is available in non-interactive shells: `bash -c 'uife'`

### Windows not opening
- Verify tmux is installed: `tmux -V`
- Check tmuxinator config location: `~/.config/tmuxinator/`
- Debug the workspace: `tmuxinator debug myworkspace`

### Panes in wrong layout
- Try different layout options: `tiled`, `even-horizontal`, `main-vertical`
- Manually adjust after launch with `Ctrl+Space` then `Ctrl+o` (cycle layouts)
