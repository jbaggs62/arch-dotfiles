# Setup Instructions

## For DEFCON - Complete System Backup

1. **Run the backup script:**
   ```bash
   cd ~/dotfiles
   ./scripts/backup.sh
   ```

2. **Push to GitHub:**
   ```bash
   git remote add origin git@github.com:jbaggs62/arch-dotfiles.git
   git push -u origin main
   ```

## Post-DEFCON - Fresh System Setup

### Method 1: Quick Setup (Recommended)
```bash
# Clone and setup in one command
bash <(curl -fsSL https://raw.githubusercontent.com/jbaggs62/arch-dotfiles/main/scripts/setup.sh) git@github.com:jbaggs62/arch-dotfiles.git
```

### Method 2: Manual Setup
```bash
# Install git and clone
sudo pacman -S git
git clone git@github.com:jbaggs62/arch-dotfiles.git ~/dotfiles
cd ~/dotfiles

# Run setup script
./scripts/setup.sh
```

## Daily Usage

### Update Package Lists
```bash
make update-packages  # or ./scripts/update-packages.sh
```

### Sync Changes
```bash
make sync  # or ./scripts/sync.sh
```

### Full Backup
```bash
make backup  # or ./scripts/backup.sh
```

## Stow Commands

### Install specific package
```bash
stow config   # Install ~/.config files
stow shell    # Install shell dotfiles  
stow local    # Install ~/.local/share files
```

### Remove package
```bash
stow -D config  # Remove ~/.config symlinks
```

### Re-install (useful after conflicts)
```bash
stow -R config  # Remove and re-install
```

## Troubleshooting

### Stow Conflicts
If stow fails due to existing files:
```bash
# Backup existing files automatically
stow --adopt config
git checkout .  # Restore your dotfiles
stow -R config  # Re-stow
```

### Missing Packages
```bash
# Install missing packages
yay -S --needed - < packages.txt
```

### Reset Everything
```bash
make unstow-all  # Remove all symlinks
make stow-all    # Re-create all symlinks
```