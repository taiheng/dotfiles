# dotfiles
----
This repository contains my bootstrapping and account configs, setup and ideas taken from https://medium.com/toutsbrasil/how-to-manage-your-dotfiles-with-git-f7aeed8adf8b and https://github.com/sam-hosseini/dotfiles

On fresh macOS install:
- Setup for a software development environment entirely with a one-liner 🔥

```
curl --silent https://raw.githubusercontent.com/taiheng/dotfiles/master/.config/bootstrap.sh | bash
```

### Getting started

Create a .dotfiles folder, which we'll use to track your dotfiles

	git init --bare $HOME/.dotfiles

create an alias `dotfiles` so you don't need to type it all over again

	alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

set git status to hide untracked files

	dotfiles config --local status.showUntrackedFiles no

add the alias to .bashrc (or .zshrc) so you can use it later

	echo "alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'" >> $HOME/.bashrc

###Usage

Now you can use regular git commands such as:

```
dotfiles status
dotfiles add .vimrc
dotfiles commit -m "Add vimrc"
dotfiles add .bashrc
dotfiles commit -m "Add bashrc"
dotfiles push
```

### Setup environment in a new computer

Make sure to have git installed, then:

clone your github repository

	git clone --bare https://github.com/USERNAME/dotfiles.git $HOME/.dotfiles

define the alias in the current shell scope

	alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

checkout the actual content from the git repository to your $HOME

	dotfiles checkout
