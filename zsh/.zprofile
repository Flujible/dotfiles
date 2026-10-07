# The following lines were added by Docker Desktop to add commands to your PATH.
export PATH="$PATH:/Users/gpalmer-bryant/.docker/bin"
# End of Docker Desktop section.

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

# Source - https://stackoverflow.com/questions/10303639/adb-command-not-found
# Posted by Denis Kutlubaev
# Retrieved 05/11/2025, License - CC-BY-SA 4.0
# Adds `adb` to the path
export PATH=~/Library/Android/sdk/platform-tools:$PATH


# Start shells pointing at the 'work' taskwarrior data
export TASKDATA=~/.task

export PATH=$HOME/.local/bin:$PATH

export HOMEBREW_PREFIX=/opt/homebrew

######################################################################
#
# SSH keys
#
######################################################################

# Ensure keys are added to SSH agent
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_personal_github
ssh-add --apple-use-keychain ~/.ssh/id_rsa_exeter_bitbucket

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

######################################################################
#
# Android development
#
######################################################################

# JDK shipped with Android Studio (the same JDK Android Studio itself
# uses for Gradle, so behaviour matches inside/outside the IDE)
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
export PATH="$JAVA_HOME/bin:$PATH"

# Android SDK location (ANDROID_HOME is legacy, ANDROID_SDK_ROOT is current — set both for compatibility)
export ANDROID_HOME="$HOME/Library/Android/sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"

# Add `emulator` to PATH (adb/platform-tools already added above)
export PATH="$ANDROID_HOME/emulator:$PATH"
