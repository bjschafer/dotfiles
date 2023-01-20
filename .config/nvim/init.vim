" vim: set sw=4 sts=4 tw=78 foldmarker={,} foldlevel=0 foldmethod=marker spell:

set nocompatible

packadd minpac

" Plugin-less settings {
if !exists('g:loaded_minpac')
    " minpac is not available, settings for plugin-less environment
" }

    " Plugins {
else
    call minpac#init()

    " minpac must have {'type': 'opt'} so that it can be loaded with `packadd`.
    call minpac#add('k-takata/minpac', {'type': 'opt'})

    " General {
    call minpac#add('vim-airline/vim-airline')          " status bar at bottom
    call minpac#add('vim-airline/vim-airline-themes')   " 
    call minpac#add('bling/vim-bufferline')

    call minpac#add('nathanaelkane/vim-indent-guides')  " shows indent level in-line
    call minpac#add('simnalamburt/vim-mundo')           " undo tree visualizer
    call minpac#add('mbbill/undotree')

    call minpac#add('scrooloose/nerdtree')               " 
    call minpac#add('jistr/vim-nerdtree-tabs')

    call minpac#add('ctrlpvim/ctrlp.vim')               " fuzzy-finder for many things
    call minpac#add('tacahiroy/ctrlp-funky')            " fuzzy-finder enhanced for many things

    call minpac#add('vim-scripts/sessionman.vim')
    call minpac#add('terryma/vim-multiple-cursors')

    call minpac#add('vim-scripts/restore_view.vim')

    call minpac#add('reedes/vim-wordy')                 " writing style checks
    " }

    " Interface plugins {
    call minpac#add('joshdick/onedark.vim')             " best colorscheme
    " }

    " Motion {
    call minpac#add('easymotion/vim-easymotion')        " \\w, \\f, \\s to enhance your jumps
    call minpac#add('christoomey/vim-tmux-navigator')   " improved nav within tmux - integrates with same plugin in tmux-land
    call minpac#add('justinmk/vim-sneak')               " s{char}{char} to go to
    call minpac#add('tpope/vim-repeat')                 " support for `.` for plugin commands
    call minpac#add('tpope/vim-surround')               " surround - parens and brackets
    " }

    " Source control {
    call minpac#add('tpope/vim-fugitive')               " git wrapper
    call minpac#add('airblade/vim-gitgutter')           " shows git information in the left gutter
    call minpac#add('rhysd/conflict-marker.vim')        " handle git merge conflicts
    " }

    " General Programming {
    call minpac#add('scrooloose/syntastic')             " syntax checking via external checkers
    call minpac#add('scrooloose/nerdcommenter')
    call minpac#add('tpope/vim-commentary')
    call minpac#add('luochen1990/rainbow')              " rainbow pair brackets
    " }

    " Go {
    if executable('go')
        call minpac#add('fatih/vim-go')
    endif
    " }

    " Python {
    call minpac#add('yssource/python.vim')
    " }

    " Misc languages {
    if executable('ansible') || executable('ansible-playbook')
        call minpac#add('Glench/Vim-Jinja2-Syntax')     " jinja syntax support
    endif
    if executable('helm')
        call minpac#add('mustache/vim-mustache-handlebars')
    endif
    if executable('terraform')
        call minpac#add('hashivim/vim-terraform')       " terraform syntax support
    endif

    if executable('dotnet')
        call minpac#add('OmniSharp/omnisharp-vim')
    endif
    call minpac#add('wsdjeg/vim-dockerfile')            " Dockerfile syntax support
    call minpac#add('elzr/vim-json')
    " }


    " Misc plugins {
    call minpac#add('dhruvasagar/vim-table-mode')       " tabularize
    call minpac#add('tpope/vim-markdown')               " better markdown support
    call minpac#add('cespare/vim-toml')                 " better toml support
    " }

    packloadall
    " }

    " Plugin settings {
    colorscheme onedark

    set statusline+=%#warningmsg#
    set statusline+=%{SyntasticStatuslineFlag()}
    set statusline+=%{fugitive#statusline()}
    set statusline+=%*

    let g:syntastic_always_populate_loc_list = 1
    let g:syntastic_auto_loc_list = 1
    let g:syntastic_check_on_open = 1
    let g:syntastic_check_on_wq = 0

    let g:syntastic_sh_shellcheck_args = "-x" " add -x to shellcheck to enable checking sources

    let g:indent_guides_enable_on_vim_startup = 1
    " it doesn't play nicely in terminal
    let g:indent_guides_auto_colors = 0
    hi IndentGuidesOdd  guibg=red   ctermbg=lightgrey
    hi IndentGuidesEven guibg=green ctermbg=darkgrey

endif
" }

" Basics {
filetype plugin indent on
syntax enable

let mapleader = ','             " map leader from '\' to ','
let maplocalleader = "_"

set background=dark

" Allow to toggle background
function! ToggleBG()
    let s:tbg = &background
    " Inversion
    if s:tbg == "dark"
        set background=light
    else
        set background=dark
    endif
endfunction
noremap <leader>bg :call ToggleBG()<CR>

set mouse=a                             " automatically enable mouse usage
set mousehide

if has('clipboard')
    if has('unnamedplus')  " When possible use + register for copy-paste
        set clipboard=unnamed,unnamedplus
    else         " On mac and Windows, use * register for copy-paste
        set clipboard=unnamed
    endif
endif

set shortmess+=filmnrxoOtT          " Abbrev. of messages (avoids 'hit enter')
set viewoptions=options,cursor,unix,slash " Better Unix / Windows compatibility
set virtualedit=onemore             " Allow for cursor beyond last character
set history=1000                    " Store a ton of history (default is 20)
set hidden                          " Allow buffer switching without saving
set iskeyword-=.                    " '.' is an end of word designator
set iskeyword-=#                    " '#' is an end of word designator
set iskeyword-=-                    " '-' is an end of word designator
" }

" Tabs settings {
set nowrap              " do not wrap long lines
set autoindent          " indent at the same level as the previous line
set shiftwidth=4        " use indents of 4 spaces
set tabstop=4           " an indentation every four columns
set expandtab           " tabs are spaces, not tabs
set smartindent         " smart autoindent when starting a new line
set nojoinspaces        " prevent inserting two spaces after punctuation on a join (J)
set pastetoggle=<f5>    " stop stupid autoindent when pasting
" }

" Backups {
if has('persistent_undo')
    " save undo tree to files in a separate location
    set undofile                " So is persistent undo ...
    set undolevels=10000        " Maximum number of changes that can be undone
    set undoreload=10000        " Maximum number lines to save for undo on a buffer reload
    set undodir=~/.config/nvim/undo
endif
" }

" Line numbers {
" press f6 to hide all line numbers, useful when copying from the terminal.
noremap <f6> :set relativenumber!<CR>:set number!<CR>

set number relativenumber

augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
augroup END
" }

" Key (re)mappings {
    " Wrapped lines goes down/up to next row, rather than next line in file.
    noremap j gj
    noremap k gk

    " Stupid shift key fixes
    if has("user_commands")
        command! -bang -nargs=* -complete=file E e<bang> <args>
        command! -bang -nargs=* -complete=file W w<bang> <args>
        command! -bang -nargs=* -complete=file Wq wq<bang> <args>
        command! -bang -nargs=* -complete=file WQ wq<bang> <args>
        command! -bang Wa wa<bang>
        command! -bang WA wa<bang>
        command! -bang Q q<bang>
        command! -bang QA qa<bang>
        command! -bang Qa qa<bang>
    endif

    " Visual shifting (does not exit Visual mode)
    vnoremap < <gv
    vnoremap > >gv

    " Allow using the repeat operator with a visual selection (!)
    " http://stackoverflow.com/a/8064607/127816
    vnoremap . :normal .<CR>

    " For when you forget to sudo.. Really Write the file.
    cmap w!! w !sudo tee % >/dev/null

    " Adjust viewports to the same size
    map <Leader>= <C-w>=
" }

" Functions {
    " Autoread on change {
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
    " }
    
    " Strip whitespace {
    function! StripTrailingWhitespace()
        " Preparation: save last search, and cursor position.
        let _s=@/
        let l = line(".")
        let c = col(".")
        " do the business:
        %s/\s\+$//e
        " clean up: restore previous search history, and cursor position
        let @/=_s
        call cursor(l, c)
    endfunction
    " }
" }
