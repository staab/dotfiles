# Config

export EDITOR='kak'

# https://unix.stackexchange.com/a/371453/85459
setopt GLOB_DOTS

alias pyr='pyr.py'
alias sum='paste -sd+ - | bc'
alias rmkak='rm ./**/*.kak.*'
alias avg="awk '{ total += \$1; count++ } END { print total/count }'"
alias lower="tr '[:upper:]' '[:lower:]'"
alias upper="tr '[:lower:]' '[:upper:]'"

. ~/.config/jstaab/path.sh
