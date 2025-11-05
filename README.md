# Dotfiles

Personal configuration files for terminal productivity and development workflow.

## Contents

### [tmux/](tmux/)
Terminal multiplexer configuration optimized for LazyVim and Vim-style workflow.
- Custom `Ctrl+Space` prefix
- Vim-style navigation and keybindings
- Mouse support and true color
- [Full documentation →](tmux/README.md)

### [tmuxinator/](tmuxinator/)
Workspace automation for launching development environments with predefined layouts.
- Frontend development workspace with test/storybook/editor windows
- Easy customization for different projects
- [Full documentation →](tmuxinator/README.md)

## Quick Start

```bash
# Clone the repository
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles

# Install tmux configuration
ln -sf $(pwd)/tmux/tmux.conf ~/.tmux.conf

# Install tmuxinator workspace
mkdir -p ~/.config/tmuxinator
ln -sf $(pwd)/tmuxinator/myworkspace.yml ~/.config/tmuxinator/myworkspace.yml

# Start your development environment
tmuxinator start myworkspace
```

## Requirements

- tmux >= 2.6
- tmuxinator (optional, for workspace automation)
- Terminal with true color support

## License

See [LICENSE.md](LICENSE.md) for details.
