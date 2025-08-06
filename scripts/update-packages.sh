#!/bin/bash
set -euo pipefail

# Package management helper script
DOTFILES_DIR="$HOME/dotfiles"

echo "📦 Updating package lists..."

cd "$DOTFILES_DIR"

# Export current package lists
yay -Qqe > packages.txt
yay -Qqem > aur-packages.txt  
yay -Qqen > official-packages.txt

# Update mise configuration
if [[ -f ~/.config/mise.toml ]]; then
    cp ~/.config/mise.toml .
    echo "  ✅ Updated mise.toml"
fi

echo "📊 Package summary:"
echo "  Total packages: $(wc -l < packages.txt)"
echo "  AUR packages: $(wc -l < aur-packages.txt)"
echo "  Official packages: $(wc -l < official-packages.txt)"

# Commit changes if git repo
if [[ -d .git ]]; then
    git add packages*.txt mise.toml
    if git diff --staged --quiet; then
        echo "  ℹ️  No package changes to commit"
    else
        git commit -m "Update package lists - $(date +%Y%m%d)"
        echo "  ✅ Package lists updated and committed"
    fi
fi