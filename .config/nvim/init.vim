packadd minpac

if !exists('g:loaded_minpac')
	" minpac is not available, settings for plugin-less environment
else
    call minpac#init()

    " minpac must have {'type': 'opt'} so that it can be loaded with `packadd`.
    call minpac#add('k-takata/minpac', {'type': 'opt'})
	
    "" conditional plugins
    if executable('puppet') || executable('pdk')
        call minpac#add('rodjek/vim-puppet')            " puppet syntax support
    endif
    if executable('ansible') || executable('ansible-playbook')
        call minpac#add('Glench/Vim-Jinja2-Syntax')     " jinja syntax support
    endif
    if executable('helm')
        call minpac#add('mustache/vim-mustache-handlebars')
    endif
    if executable('terraform')
        call minpac#add('hashivim/vim-terraform')       " terraform syntax support
    endif
    if executable('go')
        call minpac#add('fatih/vim-go')
    endif
    if executable('dotnet')
        call minpac#add('OmniSharp/omnisharp-vim')
    endif
    "" language plugins
    call minpac#add('wsdjeg/vim-dockerfile')            " Dockerfile syntax support
    call minpac#add('scrooloose/syntastic')             " syntax checking via external checkers
    "" interface plugins
    call minpac#add('joshdick/onedark.vim')             " best colorscheme
    call minpac#add('vim-airline/vim-airline')          " status bar at bottom
    call minpac#add('nathanaelkane/vim-indent-guides')  " shows indent level in-line
    call minpac#add('tpope/vim-surround')               " surround - parens and brackets
    call minpac#add('christoomey/vim-tmux-navigator')   " improved nav within tmux - integrates with same plugin in tmux-land
    call minpac#add('justinmk/vim-sneak')               " s{char}{char} to go to
    "" misc plugins
    call minpac#add('dhruvasagar/vim-table-mode')       " tabularize
    call minpac#add('airblade/vim-gitgutter')           " shows git information in the left gutter
    call minpac#add('plasticboy/vim-markdown')          " better markdown support
    call minpac#add('simnalamburt/vim-mundo')           " undo tree visualizer
    call minpac#add('tpope/vim-fugitive')               " git wrapper
    "" completion plugins
	
    " Load the plugins right now. (optional)
    packloadall
	
    filetype plugin indent on
    syntax enable
    set nocompatible
    colorscheme onedark
	
    set statusline+=%#warningmsg#
    set statusline+=%{SyntasticStatuslineFlag()}
    set statusline+=%*
    
    let g:syntastic_always_populate_loc_list = 1
    let g:syntastic_auto_loc_list = 1
    let g:syntastic_check_on_open = 1
    let g:syntastic_check_on_wq = 0

    let g:syntastic_sh_shellcheck_args = "-x" " add -x to shellcheck to enable checking sources

    let g:vim_markdown_folding_disabled = 1

    let g:indent_guides_enable_on_vim_startup = 1
    " it doesn't play nicely in terminal
    let g:indent_guides_auto_colors = 0
    hi IndentGuidesOdd  guibg=red   ctermbg=lightgrey
    hi IndentGuidesEven guibg=green ctermbg=darkgrey

endif

" tabs settings
set tabstop=4
set expandtab
set shiftwidth=4
set autoindent
set smartindent
set cindent " does proper thing for C programs, apparently.
set pastetoggle=<f5> " stop stupid autoindent when pasting
" end tabs settings

" press f6 to hide all line numbers, useful when copying from the terminal.
noremap <f6> :set relativenumber!<CR>:set number!<CR>

set number relativenumber

augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
augroup END

let mapleader = ","

" Trigger `autoread` when files changes on disk
"
" "
" https://unix.stackexchange.com/questions/149209/refresh-changed-content-of-file-opened-in-vim/383044#383044
"
" "
" https://vi.stackexchange.com/questions/13692/prevent-focusgained-autocmd-running-in-command-line-editing-mode
"
autocmd FocusGained,BufEnter,CursorHold,CursorHoldI * if mode() != 'c' | checktime | endif
"
" " Notification after file change
"
" " https://vi.stackexchange.com/questions/13091/autocmd-event-for-autoread
"
autocmd FileChangedShellPost *
 \ echohl WarningMsg | echo "File changed on disk. Buffer reloaded." | echohl None

" autodate
inoreabbr \ts\ <C-R>=strftime("%Y-%m-%d %H:%M")<CR>

" save undo tree to files
set undofile
set undodir=~/.config/nvim/undo
set undolevels=10000
