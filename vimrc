" Turn off vi compatibility
set nocompatible

" Tell vim to use more colors
let &t_Co=256

" Use syntax
syntax enable

" Colorscheme
colorscheme monokai

" Required for vundle
filetype off

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" Vundle

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" Vundle is obviously required
Plugin 'VundleVim/Vundle.vim'

" https://github.com/isRuslan/vim-es6
" Plugin 'sheerun/vim-polyglot'
Plugin 'othree/yajs.vim'
Plugin 'mxw/vim-jsx'
Plugin 'othree/es.next.syntax.vim'
let g:jsx_ext_required = 0

" https://github.com/tpope/vim-commentary
Plugin 'tpope/vim-commentary'

" https://github.com/tpope/vim-abolish
Plugin 'tpope/vim-abolish'

" https://github.com/ctrlpvim/ctrlp.vim
Plugin 'ctrlpvim/ctrlp.vim'
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_root_markers = ['.ctrlproot']
let g:ctrlp_max_files=0
let g:ctrlp_max_depth=40
let g:ctrlp_custom_ignore = 'build\|node_modules\|\v[\/]\.(git|hg|svn|pyc)$'

" https://github.com/tpope/vim-surround/#readme
Plugin 'tpope/vim-surround'

" https://github.com/jiangmiao/auto-pairs
Plugin 'jiangmiao/auto-pairs'
let g:AutoPairsMultilineClose = 0

" https://github.com/terryma/vim-multiple-cursors
Plugin 'terryma/vim-multiple-cursors'

" https://github.com/tpope/vim-markdown
Plugin 'tpope/vim-markdown'
let g:markdown_fenced_languages = ['html', 'python', 'bash=sh', 'javascript', 'yaml', 'json']

" https://github.com/bronson/vim-visual-star-search
Plugin 'bronson/vim-visual-star-search'

Plugin 'vim-scripts/indentpython.vim'

" Vim-airline
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
set laststatus=2
set ttimeoutlen=10

" vimshell
Plugin 'Shougo/vimproc.vim'
Plugin 'Shougo/vimshell.vim'

" ack.vim
Plugin 'mileszs/ack.vim'

let g:vimshell_prompt_expr =
      \ 'escape(fnamemodify(getcwd(), ":~").">", "\\[]()?! ")." "'
let g:vimshell_prompt_pattern = '^\%(\f\|\\.\)\+> '

" Register all our plugins
call vundle#end()
filetype plugin indent on
set omnifunc=syntaxcomplete#Complete


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" Settings

" Show partial commands
set showcmd

" Show line numbers
set number

" Fix indentation to snap to levels
set shiftround

" Webpack often misses default vim file save events
set backupcopy=yes

" Highlight search matches
set hlsearch                    " highlight matches

" Incremental searching
set incsearch

" Ignore case in searches
set ignorecase

" Smartcase for searching (overrides ignorecase if there's a capital letter)
set smartcase

" No wrapping
set nowrap

" Keep some context above/below the cursor
set scrolloff=10

" Default indent to 2 spaces
set tabstop=2 shiftwidth=2 softtabstop=2

" Use spaces, not tabs
set expandtab

" Backspace through everything in insert mode
set backspace=indent,eol,start

" Consistent file format
set fileformat=unix
set encoding=utf-8

" Persistent undo
set undofile                " Save undo's after file closes
set undodir=$HOME/.vim/undo " where to save undo histories
set undolevels=1000         " How many undos
set undoreload=1000        " number of lines to save for undo

" Turn of .swp files
set noswapfile

" Highlight column 80
set colorcolumn=80

" Open splits to the right and below
set splitright
set splitbelow

" Set window height/width to change based on focus
" We have to have a winheight bigger than we want to set winminheight. But if
" we set winheight to be huge before winminheight, the winminheight set will
" fail.
set winwidth=80
silent! set winminwidth=80
set winwidth=999

" Set leader and localleader
let mapleader = "\<Space>"
let maplocalleader = "\\"


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" Autocommands

" Strip trailing spaces
augroup custom_autocommands
  autocmd!
  autocmd BufWritePre * %s/\s\+$//e
augroup END


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" Language Support

""" markdown/text/html

augroup filetype_text
  autocmd!
  autocmd FileType html,markdown,text setlocal wrap

  " https://sts10.github.io/post/2016-02-12-best-of-my-vimrc/
  " j and k don't skip over wrapped lines unless given a count
  autocmd FileType html,markdown,text nnoremap <expr> j v:count ? 'j' : 'gj'
  autocmd FileType html,markdown,text nnoremap <expr> k v:count ? 'k' : 'gk'
  autocmd FileType html,markdown,text vnoremap <expr> j v:count ? 'j' : 'gj'
  autocmd FileType html,markdown,text vnoremap <expr> k v:count ? 'k' : 'gk'
augroup END

""" javascript

augroup filetype_javascript
  autocmd!
  autocmd FileType javascript setlocal autoindent tabstop=2 softtabstop=2
  autocmd FileType javascript setlocal shiftwidth=2
augroup END

""" python

augroup filetype_python
  autocmd!
  autocmd FileType python setlocal tabstop=4 softtabstop=4 shiftwidth=4
  autocmd FileType python setlocal textwidth=79 autoindent
augroup END


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" Custom mappings for general usage

" Fix fat-fingering :w
" https://stackoverflow.com/a/10590421/1467342
command! -bang -range=% -complete=file -nargs=* W <line1>,<line2>write<bang> <args>

" Enter blank newlines with enter
" http://vim.wikia.com/wiki/Insert_newline_without_entering_insert_mode
nnoremap <CR> o<Esc>
nnoremap <leader><CR> O<Esc>

" Disable automatically jumping forward with *
nnoremap * *N
vnoremap * "yy/"N

" Move lines up and down
nnoremap - ddp
nnoremap _ kddpk

" Make H and L useful
nnoremap H ^
vnoremap H ^
nnoremap L $
vnoremap L $

" When moving the cursor, scroll the window too
nnoremap <c-y> 4<c-y>
nnoremap <c-e> 4<c-e>
nnoremap <up> 5<up>
nnoremap <down> 5<down>

" Make Y work properly
nnoremap Y v$hy

" Replace annoying s key with ysiw (gotta use nmap to get at ysiw)
nmap s ysiw
vmap s S

" Shortcut to replace current window with new buffer
nnoremap <Leader>clr :new<CR><C-w><C-p>:q<CR>

""" Insert mode

" Change case of current word in insert mode
inoremap <c-U> <Esc>*Uea
inoremap <c-u> <Esc>*uea

" Allow window switching from insert mode
inoremap <c-w> <Esc><c-w>

" Insert a console log statement
iabbrev clg v => console.log(v) \|\| v

" Make scroll wheel shut up - this prevents me from using autocomplete...
" inoremap OB <nop>
" inoremap OA <nop>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" NeoVim specific

if has('nvim')
  " Shortcut for getting out of terminal mode
  tnoremap <c-\> <c-\><c-n>

  " Quick window switching while staying in terminal mode
  tnoremap <c-w>k <c-\><c-n><c-w>ki
  tnoremap <c-w><c-k> <c-\><c-n><c-w>ki
  tnoremap <c-w>j <c-\><c-n><c-w>ji
  tnoremap <c-w><c-j> <c-\><c-n><c-w>ji
  tnoremap <c-w>l <c-\><c-n><c-w>li
  tnoremap <c-w><c-l> <c-\><c-n><c-w>li
  tnoremap <c-w>h <c-\><c-n><c-w>hi
  tnoremap <c-w><c-h> <c-\><c-n><c-w>hi

  " Re-run last test in terminal context (python)
  let @t = '?\n\(FAIL\|ERROR\)' . ": jyy:newp:%s/\\n//gdf diw$pF)r.F.r:T(c^make test path=yy:q!pi:nohl"
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" Functions

function! Strip(value)
  return substitute(a:value, '^\s*\(.\{-}\)\s*$', '\1', '')
endfunction

function! OpenTerminals()
  terminal
  vs
  terminal
  sp
  terminal
  3wincmd w
  sp
  terminal
endfunction

