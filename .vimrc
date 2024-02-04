" set clipboard+=unnamedplus
let mapleader = " "
" ---------- 正常模式 ---------- ---
nnoremap <silent> <Leader>y "+y
nnoremap <silent> <Leader>p "+p
nnoremap <silent> <Leader>P "+P

" ---------- 插入模式 ---------- ---
inoremap <silent> jj <esc>

" ---------- 可视模式 ---------- ---
vnoremap <Leader>y "+y
vnoremap <Leader>p "+p
vnoremap <Leader>P "+P

" ---------- 可视行模式 ---------- ---
xnoremap <Leader>y "+y
xnoremap <Leader>p "+p
xnoremap <Leader>P "+P



" Turn syntax highlighting on.
syntax on

" Enable type file detection. Vim will be able to try to detect the type of file in use.
filetype on

" Enable plugins and load plugin for the detected file type.
filetype plugin on

" Load an indent file for the detected file type.
filetype indent on

" Disable compatibility with vi which can cause unexpected issues.
set nocompatible

" Use space characters instead of tabs.
set expandtab
set tabstop=4
set shiftwidth=4
set textwidth=80

" Add numbers to each line on the left-hand side.
set number
set relativenumber

" Highlight cursor line underneath the cursor horizontally.
set cursorline
" function s:SetCursorLine()
"     set cursorline
"     hi cursorline cterm=none ctermfg=white
" endfunction
" autocmd VimEnter * call s:SetCursorLine()

" Use a line cursor within insert mode and a block cursor everywhere else.
"
" Reference chart of values:
"   Ps = 0  -> blinking block.
"   Ps = 1  -> blinking block (default).
"   Ps = 2  -> steady block.
"   Ps = 3  -> blinking underline.
"   Ps = 4  -> steady underline.
"   Ps = 5  -> blinking bar (xterm).
"   Ps = 6  -> steady bar (xterm).
let &t_SI = "\e[6 q"
let &t_EI = "\e[2 q"
" set line when leave vim
autocmd VimLeave * call system('printf "\e[5 q" > $TTY')

" Uses a visual bell instead of an audible bell.
set visualbell

" fix backspace
set backspace=indent,eol,start

" - linebreak: Wraps long lines at a character in 'breakat' option.
set linebreak
" Allows modelines to be used in the file to set local options.

set modeline
" Specifies the number of lines at the beginning and end of the file to check for modelines.
set modelines=2
" Specifies the minimum number of lines to keep above and below the cursor when scrolling.
set scrolloff=3

" enable mouse
set mouse=a



" Automatically indents new lines based on the previous line's indentation.
set smartindent
" Automatically indents new lines to match the indentation of the previous line.
set autoindent

" - hlsearch: Highlights search matches as you type.
set hlsearch
" - incsearch: Highlights incremental search matches as you type.
set incsearch
" - ignorecase: Ignores case when searching.
set ignorecase
" - smartcase: Considers case when searching if the search pattern contains uppercase characters.
set smartcase
