#!/bin/zsh

# Refreshes the current branch against a specified target branch (default: staging).
#
# This function will:
# 1. Fetch the latest changes from the remote.
# 2. Switch to the target branch.
# 3. Pull the latest changes for the target branch.
# 4. Switch back to the original branch.
function refresh {
    local target_branch
    if [ "$1" != "" ]
    then
        target_branch="$1"
    else
        target_branch="staging"
    fi
    git fetch
    git switch $target_branch && git pull && git switch -
}

# Reverts the last commit on the current branch.
#
# This function creates a new commit that undoes the changes introduced by the HEAD commit.
function revert-last-commit {
    git revert $(git rev-parse HEAD)
}
