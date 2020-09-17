#!/bin/bash

mkdir -p ~/.config/jstaab ~/.tmuxp ~/my

ln -f src/shell.sh ~/.config/jstaab/shell.sh
ln -f src/kakrc ~/.config/kak/kakrc
ln -f src/tmux.conf ~/.tmux.conf
ln -f src/gitconfig ~/.gitconfig
ln -f src/tmuxp/cc.yaml ~/.tmuxp/cc.yaml

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo 'export PATH=$PATH:'$DIR'/pyr' >> ~/.config/jstaab/path.sh
echo "Manual steps:

- Set up ngrok.yml
- Source ~/.jstaab.sh in zshrc/fishrc/bashrc"
