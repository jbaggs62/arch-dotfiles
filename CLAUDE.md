# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository managed with GNU Stow for Arch Linux + Hyprland setup. The repository uses a structured approach for configuration management:

- **config/** - Application configurations (stowed to `~/.config/`)
- **shell/** - Shell dotfiles (stowed to `~/`)  
- **local/** - Local data files (stowed to `~/.local/share/`)
- **scripts/** - Setup and maintenance automation
- **mise.toml** - Development tool version management

## Development Environment

### Package Management Strategy

This environment uses a multi-layered package management approach:

1. **System packages**: Managed via `yay` (AUR helper for Arch Linux)
   - Package lists: `packages.txt`, `official-packages.txt`, `aur-packages.txt`
   - Install all: `yay -S --needed - < packages.txt`

2. **Development tools**: Managed via `mise`
   - Configuration: `mise.toml` (development tools with specific versions)
   - Current tools: Java, Julia, Lua 5.1, Node 22, Python, Ruby, Terraform, etc.
   - Ruby uses specific compiler settings (`CC=gcc-14 CXX=g++-14`)

### Core System Tools

Key applications configured:
- **Hyprland** - Wayland compositor with custom keybindings
- **Alacritty/Ghostty** - Terminal emulators  
- **Neovim** - LazyVim-based configuration
- **Development**: mise, yay, git, GitHub Copilot
- **Utilities**: btop, fzf, ripgrep, eza, fd, bat, zoxide

### Neovim Configuration

The Neovim setup is based on **LazyVim** with custom modifications:

**Key Files:**
- `~/.config/nvim/init.lua` - Entry point, bootstraps LazyVim
- `~/.config/nvim/lua/config/lazy.lua` - LazyVim configuration
- `~/.config/nvim/lua/config/options.lua` - Custom options (relative numbers disabled)
- `~/.config/nvim/lua/plugins/theme.lua` - Monokai Pro theme configuration
- `~/.config/nvim/plugin/after/transparency.lua` - Terminal transparency settings

**Theme and Appearance:**
- Primary theme: **Monokai Pro** (Ristretto filter)
- Transparent background enabled for terminal usage
- Custom highlight groups for transparency across various plugins (Telescope, NeoTree, notifications)

**Plugin Management:**
- Uses Lazy.nvim for plugin management
- Automatic plugin updates enabled (notifications disabled)
- Custom plugins in `lua/plugins/` directory

## Architecture Notes

### Stow-Based Configuration Management

This repository uses GNU Stow for symlink management:

- **config/** → `~/.config/*` (application configurations)
  - Hyprland, Neovim, Alacritty, btop, fastfetch, etc.
- **shell/** → `~/*` (shell dotfiles)  
  - `.bashrc`, `.bash_profile`, `.profile`, `.gitconfig`, `.XCompose`
- **local/** → `~/.local/share/*` (application data)
  - Custom application data and configurations

### Automation Scripts

**scripts/backup.sh**: Complete system backup
- Backs up config directories to Stow structure
- Exports package lists (`yay -Qqe`)
- Commits changes to git with timestamp
- Excludes sensitive directories (browsers, keyrings, cache)

**scripts/setup.sh**: Fresh system installation
- Installs yay, stow, and essential tools
- Installs packages from lists
- Creates symlinks via Stow
- Sets up mise and development tools
- Handles conflicts by backing up existing files

### Integration Points

- **mise** and shell integration via `.bashrc`
- **Stow** manages all configuration symlinks
- **Git** tracks all changes with automated commits
- **Package lists** maintain system reproducibility

## Common Commands

### Dotfiles Management

```bash
# Setup on new system
./scripts/setup.sh [repo-url]
make setup REPO=[repo-url]

# Backup current system
./scripts/backup.sh  
make backup

# Sync changes  
./scripts/sync.sh
make sync

# Update package lists
./scripts/update-packages.sh
make update-packages
```

### Stow Operations

```bash
# Install/reinstall packages
make stow-all          # Install all packages
make unstow-all        # Remove all symlinks
stow config shell local  # Install specific packages
stow -D config         # Remove config package
stow -R config         # Reinstall config package (after conflicts)

# Handle conflicts
stow --adopt config    # Backup conflicting files and create symlinks
git checkout .         # Restore original dotfiles
stow -R config         # Reinstall after resolving conflicts
```

### Development Tools (mise)

```bash
# Install/update tools
mise install              # Install all tools from mise.toml
mise list                 # Show installed tools and versions
mise use node@22          # Use specific version locally
mise self-update          # Update mise itself

# Configuration
cp mise.toml ~/.config/mise.toml  # Copy configuration
```

### Package Management (Arch/AUR)
```bash
# Install packages (official repo + AUR)
yay -S [package]

# Browse AUR with fuzzy finding
yayf

# Remove package with config files and dependencies
yay -Rns [package]
```

**Package Resources:**
- Official Arch repository + Arch User Repository (AUR)
- Browse packages: https://aur.archlinux.org/packages (~100,000 packages)  
- `yayf` provides fzf-style fuzzy finding for AUR packages

### System Maintenance

```bash
# Package list maintenance
make update-packages      # Export current package lists
yay -S --needed - < packages.txt  # Install from package list

# Configuration status
make status              # Show git and stow status  
git status               # Check for uncommitted changes

# Git workflow
git add .                # Stage changes
git commit -m "Update"   # Commit changes  
git push                 # Sync to remote repository
```

## Development Workflow

When making changes to this dotfiles repository:

1. **Edit configurations directly** in the stowed directories (config/, shell/, local/)
2. **Test changes** by re-stowing: `stow -R config` or `make stow-all`
3. **Run backup script** to sync changes: `./scripts/backup.sh` or `make backup`
4. **Commit and push** changes to maintain version control

### File Conflicts

When stow encounters existing files:
```bash
# Backup and adopt existing files
stow --adopt config
# Restore your dotfiles  
git checkout .
# Re-apply stow
stow -R config
```

### Fresh System Setup

For setting up on a new machine:
```bash
# Method 1: Quick setup
bash <(curl -fsSL https://raw.githubusercontent.com/jbaggs62/arch-dotfiles/main/scripts/setup.sh) git@github.com:jbaggs62/arch-dotfiles.git

# Method 2: Manual clone
git clone git@github.com:jbaggs62/arch-dotfiles.git ~/dotfiles
cd ~/dotfiles && ./scripts/setup.sh
```

## Important Notes

- **Stow-based symlink management**: All configs are symlinked, not copied
- **Automated backups**: The backup script automatically commits with timestamps  
- **Multi-layer package management**: System (yay) + development tools (mise)
- **Arch Linux specific**: Uses yay AUR helper and assumes Arch Linux environment
- **Hyprland desktop environment**: Configured for Wayland-based workflow