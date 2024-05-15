" gui settings
if has('gui_running')
    " enter vim
    if has("gui_gtk3")
        :set guifont=Fira\ Code\ 14
    elseif has("x11")
        " Also for GTK 1
        :set guifont=*-lucidatypewriter-medium-r-normal-*-*-180-*-*-m-*-*
    elseif has("gui_win32")
        :set guifont=Fira\ Code:h14:cANSI
    elseif has("gui_macvim")
        :set guifont=Menlo\ Regular:h14
    else
        :set guifont=Monospace\ 14
    endif
endif

"For Neovim > 0.1.5 and Vim > patch 7.4.1799 < https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162 >
"Based on Vim patch 7.4.1770 (`guicolors` option) < https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd >
" < https://github.com/neovim/neovim/wiki/Following-HEAD#20160511 >
if (has("termguicolors"))
    set termguicolors
    " set cursor style
    " Use a line cursor within insert mode and a block cursor everywhere else.
    " https://vimhelp.org/term.txt.html
    " windows notice: should be set after `set termguicolors` or `set t_Co=256`.
    " https://yianwillis.github.io/vimcdoc/doc/term.html
    " windows 注意: 应在 `set termguicolors` 或 `set t_Co=256` 之后设置。
    "
    " Reference chart of values:
    "   Ps = 0  -> blinking block.             缺省值
    "   Ps = 1  -> blinking block (default).   闪烁块
    "   Ps = 2  -> steady block.               稳定块
    "   Ps = 3  -> blinking underline.         闪烁下划线
    "   Ps = 4  -> steady underline.           稳定下划线
    "   Ps = 5  -> blinking bar (xterm).       闪烁条
    "   Ps = 6  -> steady bar (xterm).         稳定条
    "
    " imitate nvim cursor style
    " Use a line cursor within insert mode and a block cursor everywhere else.

    " insert mode
    let &t_SI = "\e[6 q"      " or \<Esc>[6 q
    " replace
    let &t_SR = "\e[4 q"
    " oherwise
    let &t_EI = "\e[2 q"
    " see term.txt raw-terminal-mode
    " when entering vim
    let &t_ti ..= "\e[2 q"
    " when leaving vim
    let &t_te ..= "\e[5 q"
else
    echoerr "Your version of Vim doesn't support termguicolors"
endif


if has('win32') || has('win64')
    " set runtimepath
    set runtimepath-=~/vimfiles
    set runtimepath^=~/.vim
    set runtimepath-=~/vimfiles/after
    set runtimepath+=~/.vim/after

    " if !has('gui_running')
        " fix cursor style (now use &t_ti &t_te)
        " need uutils-coreutils or something else
        " autocmd VimEnter * silent !printf "\e[2 q"
        " leave vim
        " pwsh support echo(Write-Output) "`e[6 q" but not useful in gvim
        " autocmd VimLeave * silent !printf "\e[6 q"
    " endif
endif

if has('unix')
    let uname = substitute(system('uname'), '\n', '', '')
    " if uname == 'Linux' || uname == 'Darwin'
        " fix cursor style (now use &t_ti &t_te)
        " enter vim
        " autocmd VimEnter * silent ! echo -ne "\e[2 q"
        " leave vim
        " autocmd VimLeave * silent ! echo -ne "\e[5 q"
    " endif
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

" colorscheme
let g:my_colorscheme = 'one'
" 检查 termguicolors 是否可用
if has("termguicolors")
    if g:my_colorscheme == 'sacredforest' && filereadable(expand("$HOME/.vim/colors/sacredforest.vim"))
        colorscheme sacredforest
    elseif g:my_colorscheme == 'one' && filereadable(expand("$HOME/.vim/colors/one.vim"))
        let g:airline_theme='one'
        if !($TERM_PROGRAM == 'alacritty')
            let g:one_allow_italics = 1
            set background=light
        else
            set background=dark
        endif
        colorscheme one
    else
        if has('win32') || has('win64')
            colorscheme retrobox
        else
            set notermguicolors
        endif

    endif
endif


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

" map <F3> :set paste<CR>
set pastetoggle=<F3>


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
if has('mouse')
    set mouse=a
else
    echoerr "Your version of Vim doesn't support mouse"
endif

" Disable compatibility with vi which can cause unexpected issues.
set nocompatible
" fix backspace
set backspace=indent,eol,start

" Use space characters instead of tabs.
set expandtab
set tabstop=4
set shiftwidth=4
set textwidth=120

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
set scrolloff=5

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
