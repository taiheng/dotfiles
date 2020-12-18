if not functions -q fisher
    set -q XDG_CONFIG_HOME; or set XDG_CONFIG_HOME ~/.config
    curl https://git.io/fisher --create-dirs -sLo $XDG_CONFIG_HOME/fish/functions/fisher.fish
    fish -c fisher
end

# set JAVA_HOME
set -x JAVA_HOME (/usr/libexec/java_home)

# Support for asdf
source (brew --prefix asdf)/asdf.fish

# Environment variables for android dev
set -x ANDROID_HOME $HOME/Library/Android/sdk
set -x ANDROID_NDK $ANDROID_HOME/ndk-bundle

