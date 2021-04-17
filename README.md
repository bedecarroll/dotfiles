# Bede's dotfiles and scripts

These are all my personal dotfiles and various scripts I've found useful. Ideally this README is to help me remeber all the features I have.

## Setup

```
# Make host specific directories
mkdir -p $XDG_CONFIG_HOME/bash/$(hostname)
mkdir -p $XDG_CONFIG_HOME/tmux/$(hostname)
# Bash history location
mkdir -p $XDG_DATA_HOME/share/bash
# Vim temp and history files
mkdir -p $XDG_DATA_HOME/vim/undo
mkdir -p $XDG_DATA_HOME/vim/swap
mkdir -p $XDG_DATA_HOME/vim/backup

# Download FZF
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.local/bin/fzf
~/.local/bin/fzf/install --all --xdg --key-bindings --completion --update-rc --no-zsh --no-fish

# Install plugged for vim
curl -fLo ~/.config/vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

## Configs

### Bash

### TMUX

### Vim

## Scripts
