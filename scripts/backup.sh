#!/bin/bash
set -euo pipefail

# Dotfiles backup script using Stow structure
DOTFILES_DIR="$HOME/dotfiles"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

echo "🔄 Starting dotfiles backup..."

# Ensure we're in the dotfiles directory
cd "$DOTFILES_DIR"

# Create Stow package directories
mkdir -p config shell local scripts

echo "📁 Backing up configuration files..."

# Backup ~/.config (excluding sensitive/large directories)
mkdir -p config/.config
find ~/.config -maxdepth 1 -type d -name "*" | while read -r dir; do
    dirname=$(basename "$dir")
    case "$dirname" in
        chromium|google-chrome*|BraveSoftware|vivaldi*|1Password|Bitwarden|Signal|Electron|dconf|pulse|cache)
            echo "  Skipping $dirname (sensitive/large directory)"
            ;;
        *)
            if [[ -d "$dir" ]]; then
                echo "  Copying $dirname..."
                cp -r "$dir" config/.config/ 2>/dev/null || true
            fi
            ;;
    esac
done

# Copy config files in ~/.config root
find ~/.config -maxdepth 1 -type f | while read -r file; do
    cp "$file" config/.config/ 2>/dev/null || true
done

echo "🐚 Backing up shell configuration..."

# Backup shell dotfiles to shell package
cp ~/.bashrc shell/.bashrc 2>/dev/null || true
cp ~/.bash_profile shell/.bash_profile 2>/dev/null || true
cp ~/.profile shell/.profile 2>/dev/null || true
cp ~/.gitconfig shell/.gitconfig 2>/dev/null || true
cp ~/.XCompose shell/.XCompose 2>/dev/null || true

echo "📦 Backing up local data..."

# Backup selective ~/.local/share contents
mkdir -p local/.local/share
find ~/.local/share -maxdepth 1 -name "*" | while read -r item; do
    itemname=$(basename "$item")
    case "$itemname" in
        cache|keyrings|gvfs-metadata)
            echo "  Skipping $itemname (cache/sensitive directory)"
            ;;
        *)
            if [[ -d "$item" ]]; then
                echo "  Copying $itemname..."
                cp -r "$item" local/.local/share/ 2>/dev/null || true
            elif [[ -f "$item" ]]; then
                cp "$item" local/.local/share/ 2>/dev/null || true
            fi
            ;;
    esac
done

echo "📋 Exporting package lists..."

# Export package lists
yay -Qqe > packages.txt
yay -Qqem > aur-packages.txt
yay -Qqen > official-packages.txt

# Copy mise configuration
cp ~/.config/mise.toml . 2>/dev/null || echo "⚠️  No mise.toml found"

echo "🔍 Checking for additional important files..."

# Check for other important dotfiles
for file in ~/.vimrc ~/.tmux.conf ~/.gitignore_global; do
    if [[ -f "$file" ]]; then
        cp "$file" "shell/$(basename "$file")"
        echo "  ✅ Backed up $(basename "$file")"
    fi
done

echo "📊 Backup summary:"
echo "  Config files: $(find config -type f | wc -l)"
echo "  Shell files: $(find shell -type f | wc -l)"
echo "  Local files: $(find local -type f | wc -l)"
echo "  Packages: $(wc -l < packages.txt)"

# Initialize git repo if not already done
if [[ ! -d .git ]]; then
    echo "🔧 Initializing git repository..."
    git init
    git add .
    git commit -m "Initial dotfiles backup - $TIMESTAMP"
    echo "📝 To push to GitHub:"
    echo "  git remote add origin <your-repo-url>"
    echo "  git push -u origin main"
else
    echo "📝 Committing changes..."
    git add .
    if git diff --staged --quiet; then
        echo "  ℹ️  No changes to commit"
    else
        git commit -m "Backup update - $TIMESTAMP"
        echo "  ✅ Changes committed"
        echo "  📤 Run 'git push' to sync to GitHub"
    fi
fi

echo "✨ Backup completed successfully!"
echo "📁 Dotfiles stored in: $DOTFILES_DIR"