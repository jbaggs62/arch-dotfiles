#!/bin/bash
set -euo pipefail

# Quick sync script for dotfiles changes
DOTFILES_DIR="$HOME/dotfiles"

echo "🔄 Syncing dotfiles..."

cd "$DOTFILES_DIR"

# Pull latest changes
if [[ -d .git ]]; then
    echo "📥 Pulling latest changes..."
    git pull
fi

# Re-stow all packages
echo "🔗 Re-stowing packages..."
for package in shell config local; do
    if [[ -d "$package" ]]; then
        echo "  Re-stowing $package..."
        stow -R "$package"
    fi
done

# Update mise tools if configuration changed
if [[ -f mise.toml && -f ~/.config/mise.toml ]]; then
    if ! cmp -s mise.toml ~/.config/mise.toml; then
        echo "🛠️  Updating mise tools..."
        cp mise.toml ~/.config/mise.toml
        ~/.local/bin/mise install
    fi
fi

echo "✨ Sync completed!"