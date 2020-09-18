#!/bin/bash

mkdir -p ~/.config/kak ~/.tmuxp ~/my

ln -f src/kakrc ~/.config/kak/kakrc
ln -f src/tmux.conf ~/.tmux.conf
ln -f src/gitconfig ~/.gitconfig
ln -f src/tmuxp/main.yaml ~/.tmuxp/main.yaml

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo "Manual steps:

- Set up ngrok.yml
- Set up path
- Source ~/.jstaab.sh in zshrc/fishrc/bashrc"
