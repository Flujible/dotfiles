
# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/gpalmer-bryant/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/gpalmer-bryant/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/gpalmer-bryant/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/gpalmer-bryant/google-cloud-sdk/completion.zsh.inc'; fi

if [ -f ~/.dotfiles/zsh/zshfunctions ]; then
    source ~/.dotfiles/zsh/zshfunctions
else
    print "404: ~/.dotfiles/zsh/zshfunctions not found."
fi

if [ -f ~/.dotfiles/zsh/zshconfig ]; then
    source ~/.dotfiles/zsh/zshconfig
else
    print "404: ~/.dotfiles/zsh/zshconfig not found."
fi