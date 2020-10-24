packadd minpac
let g:vimwiki_list = [{'path': '~/vimwiki'}] ", 'syntax': 'markdown', 'ext': '.md'}]

if !exists('*minpac#init')
	" minpac is not available, settings for plugin-less environment
else
	call minpac#init()
	
	" minpac must have {'type': 'opt'} so that it can be loaded with `packadd`.
	call minpac#add('k-takata/minpac', {'type': 'opt'})
	
        "" conditional plugins
        if executable('task')                               " taskwarrior
            call minpac#add('tools-life/taskwiki')
            call minpac#add('blindFS/vim-taskwarrior')
            call minpac#add('vimwiki/vimwiki')
        endif
        if executable('cargo')                              " cargo/rust
            call minpac#add('ncm2/ncm2-racer')
            call minpac#add('rust-lang/rust.vim')
        endif
        call minpac#add('rodjek/vim-puppet')            " puppet syntax support
        if executable('ansible') || executable('ansible-playbook')
            call minpac#add('Glench/Vim-Jinja2-Syntax')            " puppet syntax support
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
        call minpac#add('Shougo/deoplete.nvim')             " dark-powered async completion
        call minpac#add('zchee/deoplete-go')                " go completion for deoplete
        call minpac#add('zchee/deoplete-zsh')               " zsh completion for deoplete
        call minpac#add('lvht/tagbar-markdown')             " markdown tags
        call minpac#add('wsdjeg/vim-dockerfile')            " Dockerfile syntax support
        call minpac#add('PProvost/vim-ps1')                 " posh syntax
        call minpac#add('tmux-plugins/vim-tmux')            " syntax highlighting for tmux.conf
        call minpac#add('scrooloose/syntastic')             " syntax checking via external checkers
        "" interface plugins
        call minpac#add('Shougo/defx.nvim')                 " file browser
        call minpac#add('Shougo/denite.nvim')               " fuzzy finder
        call minpac#add('joshdick/onedark.vim')             " best colorscheme
        call minpac#add('vim-airline/vim-airline')          " status bar at bottom
        call minpac#add('thaerkh/vim-indentguides')         " shows indent level in-line
        call minpac#add('tpope/vim-surround')               " surround - parens and brackets
        call minpac#add('christoomey/vim-tmux-navigator')   " improved nav within tmux - integrates with same plugin in tmux-land
        "" misc plugins
        call minpac#add('scrooloose/nerdcommenter')         " better commenting
        call minpac#add('ervandew/supertab')                " perform completions in insert mode with tab
        call minpac#add('dhruvasagar/vim-table-mode')       " possibly does ^ but better
        call minpac#add('majutsushi/tagbar')                " browse tags for file in separate window
        call minpac#add('tpope/vim-fugitive')               " git
        call minpac#add('airblade/vim-gitgutter')           " shows git information in the left gutter
        call minpac#add('plasticboy/vim-markdown')          " better markdown support
        call minpac#add('tpope/vim-obsession')              " better support for sessions (similar to tmux-resurrect)
        "" completion plugins
        call minpac#add('ncm2/ncm2')                        " neovim completion manager
        call minpac#add('ncm2/ncm2-bufword')                " completion from current buffer
        call minpac#add('ncm2/ncm2-jedi')                   " python completion
        call minpac#add('ncm2/ncm2-path')                   " path completion
        call minpac#add('roxma/nvim-yarp')                  " dependency of ncm2
	
	" Load the plugins right now. (optional)
	packloadall
	
	filetype plugin indent on
	syntax enable
    set nocompatible
    colorscheme onedark
	
	let g:syntastic_always_populate_loc_list = 1
	let g:syntastic_auto_loc_list = 1
	let g:syntastic_check_on_open = 1
	let g:syntastic_check_on_wq = 1

    nmap <F8> :TagbarToggle<CR>
    
    set statusline+=%{ObsessionStatus()}
    set statusline+=%#warningmsg#
    set statusline+=%{SyntasticStatuslineFlag()}
    set statusline+=%*
    
    let g:syntastic_always_populate_loc_list = 1
    let g:syntastic_auto_loc_list = 1
    let g:syntastic_check_on_open = 1
    let g:syntastic_check_on_wq = 0

    let g:vim_markdown_folding_disabled = 1

    " ncm2 completion
    autocmd BufEnter * call ncm2#enable_for_buffer()
    set completeopt=noinsert,menuone,noselect

    " various misc keybindings
    nnoremap <silent> <F3> :Defx<Cr>
    source $HOME/.config/nvim/conf/defx.vim
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

" m support
function! MFile()

    "comment & dot level formatting
    
    let &commentstring = ';%s'
    
    let &comments = 'n:;,n:.'
    
    "autoformatting
    
    let &formatoptions = 'rol'
    
    "change word characters (default is
    '@,48-57,_,192-255')
    
    "we want to add '%' and remove '_'
    
    let &iskeyword =
    '@,%,48-57,A-Z,a-z,192-255'
    
    "enable fancy syntax hilighting
    
    source $HOME/.config/nvim/mumps.vim
 
endfunction
 
autocmd BufNewFile,BufRead *.m,ARD-*.txt,*A.ROU setfiletype mumps | call MFile()
