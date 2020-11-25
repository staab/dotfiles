#!/bin/bash

mkdir -p ~/.config/kak ~/.tmuxp ~/my

ln -f src/kakrc ~/.config/kak/kakrc
ln -f src/tmux.conf ~/.tmux.conf
ln -f src/gitconfig ~/.gitconfig
ln -f src/tmuxp/main.yaml ~/.tmuxp/main.yaml

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo "Manual steps:

- Set up ngrok.yml
- Install jq fd-find kakoune postgresql postgresql-server xsel fzf ack fish
          make zlib-devel bzip2-devel readline-devel openssl-devel libffi-devel
          llvm ncurses-devel lzma-sdk-devel libyaml-devel redhat-rpm-config
          sqlite-devel libpq-devel postgresql-contrib htop wkhtmltopdf entr
- Install nvm pyenv pipenv tmuxp yarn
