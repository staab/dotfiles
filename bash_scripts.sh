#!/bin/bash

function replace() {
  ack "$1" -l | xargs gsed -i 's@'"$1"'@'"$2"'@g'
}

function nkill() {
  ps aux | grep "$1" | awk '{print $2}' | xargs kill
}

function rename () {
  dir=$(dirname $1)

  mv "$1" "$dir/$2"
}

function cpname () {
  dir=$(dirname $1)

  cp -r "$1" "$dir/$2"
}

function w () {
  fd . "$1" | entr "${@:2}"

}

# notes
alias nl='python3 ~/Desktop/notes/src/main.py l'
alias na='python3 ~/Desktop/notes/src/main.py a'
alias nd='python3 ~/Desktop/notes/src/main.py d'

# Pyramda
alias pyr="~/Desktop/pyramda.py"

# Other tools
# https://remysharp.com/2018/08/23/cli-improved
alias top='htop'
alias chrom="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"


