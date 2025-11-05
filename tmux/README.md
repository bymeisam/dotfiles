# tmux Configuration

Tmux configuration optimized for LazyVim and development workflow.

## Features

- **Custom Prefix**: `Ctrl+Space` (instead of default `Ctrl+b`) - minimal conflicts with LazyVim
- **Vim-style Navigation**: Navigate panes with `h/j/k/l`
- **Easy Pane Splitting**:
  - `\` or `v` for vertical split
  - `-` or `s` for horizontal split
- **Pane Resizing**: `H/J/K/L` (repeatable)
- **Mouse Support**: Click to select panes, scroll, and drag borders
- **Vi Copy Mode**: Familiar Vim keybindings (`v` to select, `y` to copy)
- **True Color Support**: Full color scheme compatibility with modern terminals
- **Smart Window Management**:
  - Auto-renumbering when windows are closed
  - Windows and panes start at index 1
  - New windows/panes inherit current path
- **Fast Vim Integration**: Reduced escape time, focus events enabled
- **Custom Status Bar**: Minimalist design with date and time

## Installation

```bash
# Create symlink to tmux config
ln -sf $(pwd)/tmux.conf ~/.tmux.conf

# Reload tmux configuration (if tmux is running)
tmux source-file ~/.tmux.conf
```

## Key Bindings

All bindings start with `Ctrl+Space` (prefix):

### Pane Management
| Binding | Action |
|---------|--------|
| `Ctrl+Space` then `\` or `v` | Split pane vertically |
| `Ctrl+Space` then `-` or `s` | Split pane horizontally |
| `Ctrl+Space` then `h` | Select left pane |
| `Ctrl+Space` then `j` | Select pane below |
| `Ctrl+Space` then `k` | Select pane above |
| `Ctrl+Space` then `l` | Select right pane |
| `Ctrl+Space` then `H` | Resize pane left |
| `Ctrl+Space` then `J` | Resize pane down |
| `Ctrl+Space` then `K` | Resize pane up |
| `Ctrl+Space` then `L` | Resize pane right |

### Window Management
| Binding | Action |
|---------|--------|
| `Ctrl+Space` then `c` | Create new window |
| `Ctrl+Space` then `w` | Window picker (list view) |
| `Ctrl+Space` twice | Toggle between last two windows |

### Session Management
| Binding | Action |
|---------|--------|
| `Ctrl+Space` then `S` | Session picker (list view) |
| `Ctrl+Space` then `d` | Detach from session |

### Copy Mode
| Binding | Action |
|---------|--------|
| `Ctrl+Space` then `[` | Enter copy mode |
| `v` (in copy mode) | Begin selection |
| `y` (in copy mode) | Copy selection and exit |
| Mouse drag | Select text (stays in copy mode) |

### Misc
| Binding | Action |
|---------|--------|
| `Ctrl+Space` then `r` | Reload configuration |

## Configuration Details

### Performance Settings
- **Escape time**: 10ms (improves Vim responsiveness)
- **History limit**: 10,000 lines
- **Focus events**: Enabled for Vim autoread

### Color Settings
- **Default terminal**: `tmux-256color`
- **True color**: Enabled via terminal overrides
- **Status bar**: Custom color scheme (dark theme)

## Usage Tips

1. **Start tmux**: Simply run `tmux` in your terminal
2. **Detach**: `Ctrl+Space` then `d` - session keeps running
3. **Reattach**: `tmux attach` or `tmux a`
4. **List sessions**: `tmux ls`
5. **Mouse support**: Click and drag just works - no special commands needed
6. **Copy text**:
   - Method 1: Mouse drag and use terminal copy
   - Method 2: `Ctrl+Space` then `[`, use `v` and `y` like Vim

## Requirements

- tmux >= 2.6 (for true color support)
- Terminal with true color support (iTerm2, Alacritty, WezTerm, etc.)
- Optional: Nerd Font for better status bar icons (if extended later)

## Customization

The configuration is modular and well-commented. Key sections:

- **Lines 3-6**: Prefix key configuration
- **Lines 21-29**: Pane splitting keybindings
- **Lines 31-41**: Navigation and resizing
- **Lines 46-52**: Copy mode (Vi-style)
- **Lines 66-74**: Color and performance tuning
- **Lines 76-88**: Status bar appearance
