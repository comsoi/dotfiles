" gui settings
if has('gui_running')
    " enter vim
    if has("gui_gtk2")
        :set guifont=Fira\ Code\ 14
    elseif has("x11")
        " Also for GTK 1
        :set guifont=*-lucidatypewriter-medium-r-normal-*-*-180-*-*-m-*-*
    elseif has("gui_win32")
        :set guifont=Fira\ Code:h14:cANSI
    endif
endif

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
"
" imitate nvim cursor style
" Use a line cursor within insert mode and a block cursor everywhere else.
" insert mode
let &t_SI = "\e[6 q"
" replace
let &t_SR = "\e[4 q"
" oherwise
let &t_EI = "\e[2 q"

if has('win32') || has('win64')
    " set runtimepath
    set runtimepath-=~/vimfiles
    set runtimepath^=~/.vim
    set runtimepath-=~/vimfiles/after
    set runtimepath+=~/.vim/after

    if !has('gui_running')
        " fix cursor style
        " need uutils-coreutils or something else
        autocmd VimEnter * silent !printf "\e[2 q"
        " leave vim
        " pwsh support echo(Write-Output) "`e[6 q" but not useful in gvim
        " you can use printf.exe to print "\e[6 q"
        autocmd VimLeave * :!printf "\e[6 q"
    endif
endif



if &term =~ '^xterm'
    " enter vim
    autocmd VimEnter * silent ! echo -ne "\033[2 q"
    " leave vim
    " need \033 in git bash. \e do not support.
    autocmd VimLeave * silent !echo -ne "\033[5 q"
endif


"Use 24-bit (true-color) mode in Vim/Neovim when outside tmux.
"If you're using tmux version 2.2 or later, you can remove the outermost $TMUX check and use tmux's 24-bit color support
"(see < http://sunaku.github.io/tmux-24bit-color.html#usage > for more information.)
if (empty($TMUX))
  if (has("nvim"))
    "For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
    let $NVIM_TUI_ENABLE_TRUE_COLOR=1
  endif
endif


"For Neovim > 0.1.5 and Vim > patch 7.4.1799 < https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162 >
"Based on Vim patch 7.4.1770 (`guicolors` option) < https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd >
" < https://github.com/neovim/neovim/wiki/Following-HEAD#20160511 >
if (has("termguicolors"))
    set termguicolors
endif

" colorscheme
colorscheme sacredforest


" ---------- 快捷键 ---------- ---
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

" basic settings
" Turn syntax highlighting on.
syntax on
" Enable type file detection. Vim will be able to try to detect the type of file in use.
filetype on
" Enable plugins and load plugin for the detected file type.
filetype plugin on
" Load an indent file for the detected file type.
filetype indent on
" enable mouse
set mouse=a

" Disable compatibility with vi which can cause unexpected issues.
set nocompatible
" fix backspace
set backspace=indent,eol,start

" Use space characters instead of tabs.
set expandtab
set tabstop=4
set shiftwidth=4
set textwidth=80

" Show line numbers
set number
set relativenumber
set cursorline
set visualbell

" Allows modelines to be used in the file to set local options.
set modeline
" Specifies the number of lines at the beginning and end of the file to check for modelines.
set modelines=2
" Specifies the minimum number of lines to keep above and below the cursor when scrolling.
set scrolloff=0

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
