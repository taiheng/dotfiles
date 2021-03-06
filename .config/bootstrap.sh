#!/usr/bin/env bash

DOTFILES_REPO=$HOME/.dotfiles
DOTFILES_WORKTREE='--git-dir=$DOTFILES_REPO --work-tree=$HOME'
CONFIGS_DIR=$HOME/.config
ASDF_REPO=${HOME}/.asdf

main() {
    ask_for_sudo
    install_xcode_command_line_tools # to get "git", needed for clone_dotfiles_repo
    #accept_xcode_license
    clone_dotfiles_repo
    setup_macOS_defaults
    check_macports_installed
    install_packages_with_macports
    install_asdf
    add_asdf_plugins
    change_shell_to_fish
}

function ask_for_sudo() {
    info "Prompting for sudo password"
    if sudo --validate; then
        # Keep-alive
        while true; do sudo --non-interactive true; \
            sleep 10; kill -0 "$$" || exit; done 2>/dev/null &
        success "Sudo password updated"
    else
        error "Sudo password update failed"
        exit 1
    fi
}

function install_xcode_command_line_tools() {
    info "Installing Xcode command line tools"
    if softwareupdate --history | grep --silent "Command Line Tools"; then
        success "Xcode command line tools already exists"
    else
        xcode-select --install
        read -n 1 -s -r -p "Press any key once installation is complete"

        if softwareupdate --history | grep --silent "Command Line Tools"; then
            success "Xcode command line tools installation succeeded"
        else
            error "Xcode command line tools installation failed"
            exit 1
        fi
    fi
}

function accept_xcode_license() {
    info "Accepting Xcode license"
    sudo xcodebuild -license accept
}

function clone_dotfiles_repo() {
    info "Cloning dotfiles repository into ${DOTFILES_REPO}"
    if test -e $DOTFILES_REPO; then
        substep "${DOTFILES_REPO} already exists"
        pull_latest $DOTFILES_REPO
        success "Pull successful in ${DOTFILES_REPO} repository"
    else
        url=https://github.com/taiheng/dotfiles.git
        if git clone --bare "$url" $DOTFILES_REPO && \
           git -C $DOTFILES_REPO remote set-url origin git@github.com:taiheng/dotfiles.git && \
           git $DOTFILES_WORKTREE checkout; then
            success "Dotfiles repository cloned into ${DOTFILES_REPO}"
        else
            error "Dotfiles repository cloning failed"
            exit 1
        fi
    fi
}

function pull_latest() {
    substep "Pulling latest changes in ${1} repository"
    if git $DOTFILES_WORKTREE pull origin master &> /dev/null; then
        return
    else
        error "Please pull latest changes in ${1} repository manually"
    fi
}

function setup_macOS_defaults() {
    info "Updating macOS defaults"

    local current_dir=$(pwd)
    cd ${CONFIGS_DIR}/macOS
    if bash defaults.sh; then
        cd $current_dir
        success "macOS defaults updated successfully"
    else
        cd $current_dir
        error "macOS defaults update failed"
        exit 1
    fi
}

function install_fonts() {
    local FONT_DIR=$HOME/Library/Fonts/
    info "Syncing fonts to ${FONT_DIR}"

    rsync --archive --verbose "${CONFIGS_DIR}/fonts/" "${FONT_DIR}"
}

function check_macports_installed() {
    if hash port 2>/dev/null; then
        success "Macports installed"
    else
        error "Please install Macports"
        exit 1
    fi
}

function install_packages_with_macports() {
    local PORT_COMMANDS=${CONFIGS_DIR}/macports/packages

    if sudo port -N -F $PORT_COMMANDS; then
        success "Macport packages installed and updated"
    else
        error "Macport package installation failed"
    fi
}

function install_asdf() {
    info "Cloning asdf repo"

    if test -e $ASDF_REPO; then
        substep "${ASDF_REPO} already exists"
        pull_latest $ASDF_REPO
        success "Pull successful in ${DOTFILES_REPO} repository"
    else
        url=https://github.com/asdf-vm/asdf.git
        if git clone "${url}" $ASDF_REPO && \
            cd $ASDF_REPO && \
            git checkout "$(git describe --abbrev=0 --tags)"; then
            success "Asdf repository cloned into ${ASDF_REPO}"
        else
            error "Asdf repository cloning failed"
            exit 1
        fi
    fi
}

function add_asdf_plugins() {
    info "Adding asdf plugins"

    . ${ASDF_REPO}/asdf.sh
    
    # general ios dev tools
    asdf plugin add ruby
    asdf plugin add bundler
    asdf plugin add swiftlint

    # flutter dev
    asdf plugin add dart
    asdf plugin add flutter

    # launchgrid dev
    asdf plugin add erlang
    asdf plugin add elixir
    asdf plugin add nodejs

    # other projects
    #asdf plugin add golang
    #asdf plugin add rust

    # install versions specified in global .tool-versions
    asdf install
}

function change_shell_to_fish() {
    info "Fish shell setup"
    if grep --quiet fish <<< "$SHELL"; then
        success "Fish shell already exists"
    else
        user=$(whoami)
        substep "Adding Fish executable to /etc/shells"
        if grep --fixed-strings --line-regexp --quiet \
            "/usr/local/bin/fish" /etc/shells; then
            substep "Fish executable already exists in /etc/shells"
        else
            if echo /usr/local/bin/fish | sudo tee -a /etc/shells > /dev/null;
            then
                substep "Fish executable successfully added to /etc/shells"
            else
                error "Failed to add Fish executable to /etc/shells"
                exit 1
            fi
        fi
        substep "Switching shell to Fish for \"${user}\""
        if sudo chsh -s /opt/local/bin/fish "$user"; then
            success "Fish shell successfully set for \"${user}\""
        else
            error "Please try setting Fish shell again"
        fi
    fi
}

function coloredEcho() {
    local exp="$1";
    local color="$2";
    local arrow="$3";
    if ! [[ $color =~ '^[0-9]$' ]] ; then
       case $(echo $color | tr '[:upper:]' '[:lower:]') in
        black) color=0 ;;
        red) color=1 ;;
        green) color=2 ;;
        yellow) color=3 ;;
        blue) color=4 ;;
        magenta) color=5 ;;
        cyan) color=6 ;;
        white|*) color=7 ;; # white or invalid color
       esac
    fi
    tput bold;
    tput setaf "$color";
    echo "$arrow $exp";
    tput sgr0;
}

function info() {
    coloredEcho "$1" blue "========>"
}

function substep() {
    coloredEcho "$1" magenta "===="
}

function success() {
    coloredEcho "$1" green "========>"
}

function error() {
    coloredEcho "$1" red "========>"
}

main "$@"
