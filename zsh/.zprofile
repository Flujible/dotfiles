######################################################################
#
# Env var setup
#
######################################################################

# Setting PATH for Python 2.7
# The original version is saved in .zprofile.pysave
export PATH="/Library/Frameworks/Python.framework/Versions/2.7/bin:${PATH}"

# Setting PATH for Python 3.12
# The original version is saved in .zprofile.pysave
export PATH=/Library/Frameworks/Python.framework/Versions/3.12/bin:${PATH}

export EDITOR=nano
export VISUAL="$EDITOR"
export PATH=$PATH:/opt/homebrew/bin
export PATH=$PATH:/usr/local/share/dotnet
export PATH=$PATH:/Users/gpalmer-bryant/cloud-sql-proxy

# Start shells pointing at the 'work' taskwarrior data
export TASKDATA=~/.task

export HOMEBREW_PREFIX=/opt/homebrew

######################################################################
#
# SSH keys
#
######################################################################

# Ensure keys are added to SSH agent
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_personal_github

######################################################################
#
# GCP CLI setup
#
######################################################################

# The next line updates PATH for the Google Cloud SDK.
if [ -f ~/google-cloud-sdk/path.zsh.inc ]; then
    . ~/google-cloud-sdk/path.zsh.inc;
else
    print "Could not find gcloud path.zsh.inc"
fi

# The next line enables shell command completion for gcloud.
if [ -f ~/google-cloud-sdk/completion.zsh.inc ]; then
    . ~/google-cloud-sdk/completion.zsh.inc;
else
    print "Could not find gcloud completion.zsh.inc"
fi
