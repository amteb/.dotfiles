# Tmux Configuration Architecture

Clean separation between behavior, structure, and appearance following Unix philosophy.

## File Organization

```
tmux/
├── tmux.conf                    # Main config: keybindings, behavior, source order
├── reset.conf                   # Unsets color variables (theme reset)
├── components/
│   └── minimalist.tmux.conf    # Structure & layout (NO colors)
└── themes/
    ├── default.tmux.conf        # Fallback theme (terminal colors)
    └── monokai-pro-machine.tmux.conf  # Monokai Pro Machine palette
```

## Design Principles

### 1. Separation of Concerns

**tmux.conf** - Behavior only
- Keybindings
- Window/pane settings
- Terminal capabilities
- Plugin loading
- Source order orchestration

**reset.conf** - Color variable cleanup
- Unsets all `@text_*`, `@border_*`, `@bg_*` variables
- Does NOT touch behavior settings
- Used before loading new themes

**components/*.tmux.conf** - Structure only
- Status bar layout and format
- Component definitions (`$c_session`, `$c_mode`, etc.)
- Visual positioning (absolute-centre, top, etc.)
- References color variables via `#{@text_*}`, `#{@border_*}`, `#{@bg_*}`
- **Contains ZERO hardcoded colors**

**themes/*.tmux.conf** - Colors only
- Sets ONLY color variables
- No layout, no behavior, no structure
- Pure palette definitions

### 2. Unix Philosophy

Each file does **one thing** well:
- Easy to test in isolation
- Swap themes without breaking layout
- Add new components without touching colors
- Modify behavior without affecting appearance

### 3. Transparent by Default

All backgrounds use `bg=default` to respect terminal transparency settings.

## Theme Variable Contract

Themes MUST define these variables for components to work:

```tmux
# Required text colors
@text_main              # Primary text
@text_selected          # Selected window text
@text_unselected        # Inactive windows
@text_unselected_recent # Last active window
@text_active            # Current window
@text_secondary         # Secondary indicators
@text_tertiary          # Tertiary indicators
@text_accent            # Highlight/accent text
@text_sync              # Synchronized pane indicator

# Required border colors
@border_active          # Active pane border
@border_inactive        # Inactive pane border

# Required backgrounds
@bg_visual              # Visual selection background
```

## Usage

### Switch Themes

Edit `tmux.conf` to source a different theme:

```tmux
# Option 1: Monokai Pro Machine
source ~/.config/tmux/themes/monokai-pro-machine.tmux.conf

# Option 2: Terminal defaults
source ~/.config/tmux/themes/default.tmux.conf

# Option 3: Your custom theme
source ~/.config/tmux/themes/my-theme.tmux.conf
```

Then reload: `tmux source-file ~/.config/tmux/tmux.conf`

### Create a New Theme

1. Copy an existing theme:
   ```bash
   cp themes/default.tmux.conf themes/my-theme.tmux.conf
   ```

2. Edit color values ONLY - don't add structure/layout

3. Source it in `tmux.conf`

4. Reload tmux

### Dynamic Theme Switching (Plugin Integration)

For plugins that dynamically update colors:

```bash
# In your plugin:
# 1. Source reset.conf to clear old colors
tmux source-file ~/.config/tmux/reset.conf

# 2. Set new color variables
tmux set -g @text_main "#new_color"
tmux set -g @text_active "#another_color"
# ... set all required variables

# 3. Refresh display
tmux refresh-client -S
```

The minimalist components will automatically use the new colors without modification.

## Component Architecture

Components are defined as tmux variables (`$c_*`) that can be composed:

- `$c_session` - Session name display
- `$c_mode` - Mode indicator (copy/sync/prefix)
- `$c_window_text` - Window display format
- `$c_active_window` - Current window style
- `$c_inactive_window` - Inactive window style

These are used in status bar sections:
```tmux
set -g status-left "$c_session"
set -g status-right "$c_mode %H:%M %d-%b-%y"
set -g window-status-current-format "$c_active_window"
```

## Testing

Verify configuration loads without errors:
```bash
tmux source-file ~/.config/tmux/tmux.conf
```

Test theme switching:
```bash
# Edit tmux.conf to source different theme
# Reload
tmux source-file ~/.config/tmux/tmux.conf
```

## Modular Philosophy Benefits

✅ **Maintainability** - Each file has single responsibility  
✅ **Composability** - Mix and match themes + components  
✅ **Testability** - Verify each layer independently  
✅ **Portability** - Themes work across different tmux setups  
✅ **Extensibility** - Add components without breaking themes  
✅ **Plugin-friendly** - Dynamic color updates just work
