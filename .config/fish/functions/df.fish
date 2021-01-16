function df --description 'Alias dotfiles'
    if count $argv > /dev/null
        dotfiles $argv
    else
        dotfiles status
    end
end