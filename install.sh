#!/usr/bin/env bash

echo "Setting up symlinks..."
ln -sf ~/.dotfiles/gitconfig/.gitconfig ~/.gitconfig
ln -sf ~/.dotfiles/zsh/.zshrc ~/.zshrc
ln -sf ~/.dotfiles/zsh/.zprofile ~/.zprofile
ln -sf ~/.dotfiles/taskwarrior/.taskrc ~/.taskrc

mkdir -p ~/.task

setup_tw_hooks_symlink() {
    local source_dir="$HOME/.dotfiles/taskwarrior/hooks"
    local target_dir="$HOME/.task/hooks"

    # Guard Clause: If it's a real directory AND is not empty, abort to prevent data loss
    if [ -d "$target_dir" ] && [ ! -L "$target_dir" ] && [ -n "$(ls -A "$target_dir")" ]; then
        echo "Warning: $target_dir is not empty. Skipping hooks symlink."
        return
    fi

    # Clean up: If it's an empty, real directory, remove it safely
    if [ -d "$target_dir" ] && [ ! -L "$target_dir" ]; then
        rmdir "$target_dir"
    fi

    ln -sf "$source_dir" "$target_dir"
}

setup_tw_hooks_symlink

echo "Symlinks created."

source ~/.dotfiles/scripts/build_helpers.sh

######################################################################
#
# Tickli - TickTick CLI
#
######################################################################

TICKLI_REPO="https://github.com/Flujible/tickli.git"
TICKLI_INSTALL_DIR="$HOME/.local/bin"

if ! command -v go &> /dev/null; then
    echo "WARNING: go is not installed. Skipping tickli installation."
    echo "Install Go (https://go.dev/dl/) and re-run this script to install tickli."
elif ! needs_rebuild "$TICKLI_REPO" "tickli"; then
    echo "tickli is up to date ($(cat "$STAMP_DIR/tickli"))."
else
    mkdir -p "$TICKLI_INSTALL_DIR"
    TICKLI_TMP="$(mktemp -d)"
    echo "Cloning tickli from $TICKLI_REPO..."
    git clone "$TICKLI_REPO" "$TICKLI_TMP"
    echo "Building tickli..."
    (cd "$TICKLI_TMP" && go build -o "$TICKLI_INSTALL_DIR/tickli" .)
    rm -rf "$TICKLI_TMP"
    record_build "tickli"
    echo "tickli installed to $TICKLI_INSTALL_DIR/tickli (${REMOTE_HEAD:0:8})"
    echo ""
    echo "To complete tickli setup:"
    echo "  1. Add your TickTick API credentials to ~/.dotfiles/.tickli.secrets"
    echo "     (see ~/.dotfiles/.secrets.example for the required format)"
    echo "  2. Open a new terminal so the secrets are loaded"
    echo "  3. Run 'tickle init' to authenticate with TickTick"
    echo ""
    if [ -f "$HOME/.dotfiles/.tickli.secrets" ]; then
        echo "  (credentials found at ~/.dotfiles/.tickli.secrets)"
    else
        echo "  (no credentials found - create ~/.dotfiles/.tickli.secrets)"
    fi
fi
