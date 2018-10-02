# Basic options ├───────────────────────────────────────────────────────────────────

# Load editorconfig automatically
hook global BufCreate .* %{editorconfig-load}

# Show line numbers
addhl global/ number_lines

# Indent/deindent rather than insert tabs
map global insert <tab> 'x<a-;><gt><backspace>'
map global insert <s-tab> '<a-;><lt>'

# Tab width
set-option global tabstop 2
set-option global indentwidth 2

# Keep a few lines on screen
set-option global scrolloff 3,5

# Autoreload changed files
set-option global autoreload yes

# Plugins ├──────────────────────────────────────────────────────────────────────────

# Custom functions ├─────────────────────────────────────────────────────────────────

# Open kakoune config
def conf -docstring 'Open kakrc' %{ e ~/.config/kak/kakrc }

# Use fzf to fuzzy find stuff
def fzf-file -docstring 'Fuzzy find' %{ %sh{
    if [ -z "$TMUX" ]; then
      echo echo only works inside tmux
    else
      FILE=$(ack '.*' -l | fzf-tmux -d 15)
      if [ -n "$FILE" ]; then
        printf 'eval -client %%{%s} edit %%{%s}\n' "${kak_client}" "${FILE}" | kak -p "${kak_session}"
      fi
    fi
} }

# Split windows using tmux
def vs -docstring "Open a vertical split" \
    %{ %sh{ tmux split-window -h -c '#{pane_current_path}' kak -c "${kak_session}" } }
def sp -docstring "Open a horizontal split" \
    %{ %sh{ tmux split-window -v -c '#{pane_current_path}' kak -c "${kak_session}" } }

# Fix fat-fingering :w
def W -docstring "Write current buffer to file" %{ w }

# Move through buffers and write
def wn -docstring "Write and go to buffer-next" %{ w; buffer-next }

def rm -docstring "Remove current file" %{ %sh{ rm "${kak_buffile}" } }

def clj-eval -docstring "Eval selection in current clojure repl" %{
  echo %sh{
    echo "$kak_selection" | nc localhost 5555 | sed \$d | sed -e 's/^.*> //g'
  }
}

# Custom modes ├─────────────────────────────────────────────────────────────────

# Add custom surround mode - note that this is touchy; curly brackets can't be
# escaped inside expansions, but may be nested, which is why { always comes before }
def -hidden surround-mode %{
  info -title Commands %{
    ': surround with single quotes
    ": surround with double quotes
    { or }: surround with curly brackets
    [ or ]: surround with square brackets
    ( or ): surround with parentheses
  }
  on-key %{ %sh{
    case $kak_key in
      "'") echo exec "i'<esc>a'<esc><a-\;>H" ;;
      '"') echo exec 'i"<esc>a"<esc><a-\;>H' ;;
      [\{\}]) echo exec 'i{<esc>a}<esc><a-\;>H' ;;
      [\[\]]) echo exec 'i[<esc>a]<esc><a-\;>H' ;;
      [\(\)]) echo exec 'i(<esc>a)<esc><a-\;>H' ;;
    esac
  }}
}

# Custom case change mode
def -hidden case-change-mode %{
  info -title Commands %{
    c: camel case
    p: pascal case
    s: snake case
    k: kebab case
  }
  on-key %{ %sh{
    case $kak_key in
      c) echo exec '`s[-_<space>]<ret>d~<a-i>w' ;;
      p) echo exec '`s[-_<space>]<ret>d~b\;~<a-i>w' ;;
      s) echo exec '<a-:><a-\;>s-|[a-z][A-Z]<ret>\;a<space><esc>s[-\s]+<ret>c_<esc><a-i>w`' ;;
      k) echo exec '<a-:><a-\;>s_|[a-z][A-Z]<ret>\;a<space><esc>s[_\s]+<ret>c-<esc><a-i>w`' ;;
    esac
  }}
}

def -hidden clj-eval-tree %{
  info -title Commands %{
    s: selection
    l: line
  }
  on-key %{ %sh{
    case $kak_key in
      s) echo exec ':clj-eval<ret>' ;;
      l) echo exec 'x:clj-eval<ret>' ;;
    esac
  }}
}

def wrap -docstring "Wrap buffer" %{ exec ':addhl buffer wrap<ret>' }

# Custom mappings ├────────────────────────────────────────────────────────────────

# Copy/paste with system clipboard
map global user p -docstring "Paste from system clipboard" '<a-!>reattach-to-user-namespace pbpaste<ret>'
hook global NormalKey y|d|c %{ nop %sh{
  printf %s "$kak_reg_dquote" | reattach-to-user-namespace pbcopy
}}

# Map to custom commands
map global user s -docstring 'Surround mode' ':surround-mode<ret>'
map global user c -docstring 'Case Change mode' ':case-change-mode<ret>'
map global user , -docstring 'Fuzzy find' ':fzf-file<ret>'
map global user <ret> -docstring 'Add newline before cursor' i<ret><esc>

# Move selection up/down
map global normal <a-minus> '<a-x>dkPk'
map global normal <minus> '<a-x>dpj'

# Comment hotkey
map global normal '#' :comment-line<ret>

# Case-insensitive search by default
map -docstring 'case insensitive search' global normal '/' /(?i)
map -docstring 'case insensitive backward search' global normal '<a-/>' <a-/>(?i)
map -docstring 'case insensitive extend search' global normal '?' ?(?i)
map -docstring 'case insensitive backward extend-search' global normal '<a-?>' <a-?>(?i)

# Add newline with enter
map global normal <ret> o<esc>
map global normal <a-ret> O<esc>

# Highlighters ├────────────────────────────────────────────────────────────────

add-highlighter shared/ group tabs
add-highlighter shared/tabs regex \t+ 0:default,blue

add-highlighter shared/ group trailing_white_spaces
add-highlighter shared/trailing_white_spaces regex \h+$ 0:Error

add-highlighter shared/ group current_search
add-highlighter shared/current_search dynregex '%reg{/}' 0:MatchingChar

# Only shown when not in insert mode

hook global ModeChange insert:normal %{
  add-highlighter window ref tabs
  add-highlighter window ref trailing_white_spaces
  add-highlighter window ref current_search
}

hook global ModeChange normal:insert %{
  remove-highlighter window/tabs
  remove-highlighter window/trailing_white_spaces
  remove-highlighter window/current_search
}

# Filters ├─────────────────────────────────────────────────────────────────────

define-command clean %{
  clean-whitespaces
}

define-command -hidden clean-whitespaces %{
  evaluate-commands -draft -itersel %{
    try %{ execute-keys -draft -itersel s <ret>d } catch %{ echo '' }
    try %{ execute-keys -draft -itersel s^\h+|\h+$<ret>d } catch %{ echo '' }
    try %{ execute-keys -draft -itersel s\h+<ret>c<space> } catch %{ echo '' }
  }
}

# File type ├───────────────────────────────────────────────────────────────────

hook global WinSetOption filetype=javascript %{
  colorscheme desertex
  set-option buffer comment_line '// '
}

hook global WinSetOption filetype=python %{
  set-option buffer tabstop     4
  set-option buffer indentwidth 4
  set-option buffer comment_line '# '
}

hook global WinSetOption filetype=sh %{
  set-option buffer tabstop     2
  set-option buffer indentwidth 2
  set-option buffer comment_line '// '
}

hook global WinSetOption filetype=clojure %{
  set-option buffer comment_line ';; '
  map buffer user e -docstring 'Eval clojure code' ':clj-eval-tree<ret>'
}
