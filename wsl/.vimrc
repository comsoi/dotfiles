" copy (write) highlighted text to .vimbuffer
vmap <C-c> y:new ~/.vimbuffer<CR>VGp:x<CR> \| :!cat ~/.vimbuffer \| /mnt/c/Windows/System32/clip.exe <CR><CR>
" paste from buffer
map <C-v> :r ~/.vimbuffer<CR>

" ---------- 剪贴板处理 全局 ---------- ---
autocmd TextYankPost * call YankDebounced()

function! Yank(timer)
    call system('win32yank.exe -i --crlf', @")
    redraw!
endfunction

let g:yank_debounce_time_ms = 500
let g:yank_debounce_timer_id = -1

function! YankDebounced()
    let l:now = localtime()
    call timer_stop(g:yank_debounce_timer_id)
    let g:yank_debounce_timer_id = timer_start(g:yank_debounce_time_ms, 'Yank')
endfunction
" #---------- 剪贴板处理 全局 ---------- ---

" ---------- 剪贴板处理 ---------- ---
" WSL clipboard with win32yank
" 检查 win32yank 是否可执行
if executable('win32yank.exe')
  augroup WSLYank
    autocmd!
    " 当执行复制操作后，使用 win32yank 将文本复制到 Windows 剪贴板
    autocmd TextYankPost * if v:event.operator ==# 'y' | call system('win32yank.exe -i --crlf', @0) | endif
  augroup END
endif

let mapleader = " "
inoremap <silent> jj <esc>