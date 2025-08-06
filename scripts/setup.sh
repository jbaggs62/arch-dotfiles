#!/bin/bash
set -euo pipefail

# Dotfiles setup script for fresh Arch installation
DOTFILES_DIR="$HOME/dotfiles"
REPO_URL="${1:-}"

echo "🚀 Setting up dotfiles environment..."

# Check if we're already in dotfiles directory
if [[ "$(basename "$PWD")" == "dotfiles" ]]; then
    DOTFILES_DIR="$PWD"
    echo "📁 Using current directory: $DOTFILES_DIR"
elif [[ -d "$DOTFILES_DIR" ]]; then
    echo "📁 Using existing dotfiles: $DOTFILES_DIR"
    cd "$DOTFILES_DIR"
else
    if [[ -z "$REPO_URL" ]]; then
        echo "❌ Please provide repository URL or run from dotfiles directory"
        echo "Usage: $0 <github-repo-url>"
        exit 1
    fi
    echo "📥 Cloning dotfiles repository..."
    git clone "$REPO_URL" "$DOTFILES_DIR"
    cd "$DOTFILES_DIR"
fi

echo "🔧 Installing essential tools..."

# Install yay if not present
if ! command -v yay &> /dev/null; then
    echo "  Installing yay..."
    sudo pacman -S --needed git base-devel
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd "$DOTFILES_DIR"
fi

# Install stow if not present
if ! command -v stow &> /dev/null; then
    echo "  Installing stow..."
    sudo pacman -S --needed stow
fi

echo "📦 Installing packages..."

# Install packages from lists
if [[ -f packages.txt ]]; then
    echo "  Installing all packages..."
    yay -S --needed - < packages.txt
elif [[ -f official-packages.txt && -f aur-packages.txt ]]; then
    echo "  Installing official packages..."
    yay -S --needed - < official-packages.txt
    echo "  Installing AUR packages..."
    yay -S --needed - < aur-packages.txt
else
    echo "  ⚠️  No package lists found, skipping package installation"
fi

echo "🔗 Creating symbolic links with Stow..."

# Remove existing dotfiles that would conflict
echo "  Backing up existing dotfiles..."
mkdir -p "$HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"
for file in ~/.bashrc ~/.bash_profile ~/.profile ~/.gitconfig ~/.XCompose; do
    if [[ -f "$file" && ! -L "$file" ]]; then
        mv "$file" "$HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)/"
        echo "    Backed up $(basename "$file")"
    fi
done

# Stow packages
for package in shell config local; do
    if [[ -d "$package" ]]; then
        echo "  Stowing $package..."
        stow -v "$package" 2>/dev/null || {
            echo "    ⚠️  Conflicts detected for $package, backing up and retrying..."
            # Handle conflicts by backing up existing files
            stow -v --adopt "$package" 2>/dev/null || true
            stow -R "$package"
        }
    fi
done

echo "🛠️  Setting up development tools..."

# Install mise if not present
if ! command -v mise &> /dev/null; then
    echo "  Installing mise..."
    curl https://mise.jdx.dev/install.sh | sh
    echo 'eval "$(mise activate bash)"' >> ~/.bashrc
fi

# Install development tools
if [[ -f mise.toml ]]; then
    echo "  Installing development tools with mise..."
    cp mise.toml ~/.config/mise.toml
    ~/.local/bin/mise install
fi

echo "🔄 Refreshing shell environment..."

# Source new configurations
if [[ -f ~/.bashrc ]]; then
    source ~/.bashrc || true
fi

echo "🎨 Setting up additional configurations..."

# Refresh XCompose if present
if [[ -f ~/.XCompose ]] && command -v refresh-xcompose &> /dev/null; then
    refresh-xcompose
fi

# Set up git if not configured
if ! git config --global user.name &> /dev/null; then
    echo "🔧 Git configuration required:"
    read -p "Enter your git username: " git_username
    read -p "Enter your git email: " git_email
    git config --global user.name "$git_username"
    git config --global user.email "$git_email"
fi

echo "✨ Setup completed successfully!"
echo ""
echo "📋 Next steps:"
echo "  1. Restart your shell or run: source ~/.bashrc"
echo "  2. Check installed tools: mise list"
echo "  3. Customize configurations as needed"
echo "  4. Run backup.sh to sync any changes back to git"
echo ""
echo "🏠 Dotfiles location: $DOTFILES_DIR"
echo "💾 Backup location: ~/.dotfiles-backup/"