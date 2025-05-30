#!/bin/zsh

function mkcd() {
    mkdir -p "$@" && cd "$_";
}
