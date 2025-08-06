# Dotfiles

Personal configuration files managed with GNU Stow for Arch Linux + Hyprland setup.

## Structure

- `config/` - Application configurations (`~/.config/`)
- `shell/` - Shell dotfiles (`~/.bashrc`, `.profile`, etc.)
- `local/` - Local data files (`~/.local/share/`)
- `scripts/` - Setup and maintenance scripts

## Quick Setup

```bash
# Clone and setup
git clone git@github.com:jbaggs62/arch-dotfiles.git ~/dotfiles
cd ~/dotfiles
./scripts/setup.sh
```

## Manual Stow Usage

```bash
# Install specific packages
stow config  # ~/.config/* files
stow shell   # Shell configuration
stow local   # ~/.local/share/* files

# Remove package
stow -D config
```

## Backup Current System

```bash
./scripts/backup.sh
```

## Package Management

- `packages.txt` - Official + AUR packages (`yay -S - < packages.txt`)
- `mise.toml` - Development tools managed by mise