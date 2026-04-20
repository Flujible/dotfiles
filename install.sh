echo "Setting up symlinks..."
ln -sf ~/.dotfiles/gitconfig/.gitconfig ~/.gitconfig
ln -sf ~/.dotfiles/zsh/.zshrc ~/.zshrc
ln -sf ~/.dotfiles/zsh/.zprofile ~/.zprofile
ln -sf ~/.dotfiles/taskwarrior/.taskrc ~/.taskrc
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
fi
