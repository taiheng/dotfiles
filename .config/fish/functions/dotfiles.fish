function dotfiles --description 'git wrapper for managing dotfiles in a git repo'
    git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME $argv
end
