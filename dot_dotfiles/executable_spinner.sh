#!/usr/bin/env bash

# This works in bash but not zsh

spinner() {
    local i sp n
    sp='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    n=${#sp}
    printf ' '
    while sleep 0.1; do
        # Don't @ me
        printf "%s\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b" "${sp:i++%n:1} Installing..."
    done
}

printf 'Doing important work '
spinner &

sleep 10  # sleeping for 10 seconds is important work

kill "$!" # kill the spinner
printf '\n'
