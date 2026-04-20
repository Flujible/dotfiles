#!/bin/bash

STAMP_DIR="$HOME/.local/share/dotfiles-stamps"

# Check if a remote repo has new commits since last build.
# Usage: needs_rebuild <repo_url> <stamp_name>
# Returns 0 (true) if a rebuild is needed, 1 (false) if up to date.
# Sets REMOTE_HEAD to the latest commit hash for use after calling.
needs_rebuild() {
    local repo_url="$1"
    local stamp_name="$2"
    local stamp_file="$STAMP_DIR/$stamp_name"

    REMOTE_HEAD="$(git ls-remote "$repo_url" HEAD | cut -f1)"
    local local_head=""
    if [ -f "$stamp_file" ]; then
        local_head="$(cat "$stamp_file")"
    fi

    [ "$REMOTE_HEAD" != "$local_head" ]
}

# Record the current remote HEAD as the last-built commit.
# Usage: record_build <stamp_name>
record_build() {
    local stamp_name="$1"
    mkdir -p "$STAMP_DIR"
    echo "$REMOTE_HEAD" > "$STAMP_DIR/$stamp_name"
}
