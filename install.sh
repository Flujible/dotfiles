#!/usr/bin/env bash

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

######################################################################
#
# Package Manager Provisioning (Homebrew & Oh My Zsh)
#
######################################################################

# 1. Install Homebrew if missing
if ! command -v brew &>/dev/null; then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [ -x "/opt/homebrew/bin/brew" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x "/usr/local/bin/brew" ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
fi

# 2. Run brew bundle if Brewfile exists
if [ -f "$DOTFILES_DIR/Brewfile" ]; then
    echo "Installing packages from Brewfile..."
    brew bundle --file="$DOTFILES_DIR/Brewfile"
    echo ""
fi

# 3. Install Oh My Zsh if missing
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Oh My Zsh not found. Installing Oh My Zsh..."
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    echo ""
fi

######################################################################
#
# Symlinks Setup (Idempotent)
#
######################################################################

safe_symlink() {
    local source="$1"
    local target="$2"

    if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
        return
    fi

    if [ -e "$target" ] && [ ! -L "$target" ]; then
        echo "Warning: $target already exists and is not a symlink. Skipping."
        return
    fi

    mkdir -p "$(dirname "$target")"
    ln -sf "$source" "$target"
    echo "Linked $target -> $source"
}

echo "Setting up symlinks..."
safe_symlink "$DOTFILES_DIR/gitconfig/.gitconfig" "$HOME/.gitconfig"
safe_symlink "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
safe_symlink "$DOTFILES_DIR/zsh/.zprofile" "$HOME/.zprofile"
safe_symlink "$DOTFILES_DIR/taskwarrior/.taskrc" "$HOME/.taskrc"

setup_tw_hooks_symlink() {
    local source_dir="$DOTFILES_DIR/taskwarrior/hooks"
    local target_dir="$HOME/.task/hooks"

    if [ -L "$target_dir" ] && [ "$(readlink "$target_dir")" = "$source_dir" ]; then
        return
    fi

    if [ -d "$target_dir" ] && [ ! -L "$target_dir" ] && [ -n "$(ls -A "$target_dir")" ]; then
        echo "Warning: $target_dir is not empty. Skipping hooks symlink."
        return
    fi

    if [ -d "$target_dir" ] && [ ! -L "$target_dir" ]; then
        rmdir "$target_dir"
    fi

    mkdir -p "$HOME/.task"
    ln -sf "$source_dir" "$target_dir"
    echo "Linked $target_dir -> $source_dir"
}

setup_tw_hooks_symlink
echo "Symlink configuration up to date."
echo ""

######################################################################
#
# Healthcheck: Required & Recommended Tools
#
######################################################################

echo "Running environment healthcheck..."

missing_count=0

check_cmd() {
    local cmd="$1"
    local hint="$2"

    if command -v "$cmd" &>/dev/null; then
        printf "  [\033[32m✓\033[0m] %-14s (%s)\n" "$cmd" "$(command -v "$cmd")"
    else
        printf "  [\033[31m✗\033[0m] %-14s missing - %s\n" "$cmd" "$hint"
        ((missing_count++))
    fi
}

check_path() {
    local path="$1"
    local label="$2"
    local hint="$3"

    if [ -e "$path" ]; then
        printf "  [\033[32m✓\033[0m] %-14s (%s)\n" "$label" "$path"
    else
        printf "  [\033[31m✗\033[0m] %-14s missing - %s\n" "$label" "$hint"
        ((missing_count++))
    fi
}

echo ""
echo "CLI tools:"
check_cmd "git" "Install via Xcode Command Line Tools or Homebrew"
check_cmd "brew" "Install from https://brew.sh"
check_cmd "task" "Install via 'brew install task'"
check_cmd "timew" "Install via 'brew install timewarrior'"
check_cmd "terraform" "Install via 'brew install terraform'"
check_cmd "gcloud" "Install Google Cloud SDK"
check_cmd "conda" "Install Miniforge / Mambaforge"

echo ""
echo "Frameworks & Plugins:"
check_path "$HOME/.oh-my-zsh" "oh-my-zsh" "Install from https://ohmyz.sh"
check_path "$HOME/.nvm" "nvm" "Install from https://github.com/nvm-sh/nvm"

BREW_PREFIX="${HOMEBREW_PREFIX:-/opt/homebrew}"
check_path "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" "autosuggestions" "Install via 'brew install zsh-autosuggestions'"

echo ""
if [ "$missing_count" -eq 0 ]; then
    printf "\033[32mAll tools and dependencies are satisfied!\033[0m\n"
else
    printf "\033[33mHealthcheck completed with %d missing item(s).\033[0m\n" "$missing_count"
fi
