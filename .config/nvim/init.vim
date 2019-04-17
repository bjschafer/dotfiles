packadd minpac

if !exists('*minpac#init')
	" minpac is not available, settings for plugin-less environment
else
	call minpac#init()
	
	" minpac must have {'type': 'opt'} so that it can be loaded with `packadd`.
	call minpac#add('k-takata/minpac', {'type': 'opt'})
	
	" Add other plugins here.
        call minpac#add('tpope/vim-fugitive')
        call minpac#add('tpope/vim-surround')
        call minpac#add('airblade/vim-gitgutter')
        call minpac#add('vim-airline/vim-airline')
        call minpac#add('scrooloose/nerdcommenter')
        call minpac#add('scrooloose/syntastic')
        call minpac#add('ervandew/supertab')
        call minpac#add('nathanaelkane/vim-indent-guides')
        call minpac#add('ekalinin/dockerfile.vim')
        call minpac#add('joshdick/onedark.vim')
        if exists('task')
            call minpac#add('vimwiki/vimwiki')
            call minpac#add('blindFS/vim-taskwarrior')
            call minpac#add('tbabej/taskwiki')
        endif
        call minpac#add('tpope/vim-obsession')
        call minpac#add('majutsushi/tagbar')
        call minpac#add('rust-lang/rust.vim')
	
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

        let g:vimwiki_list = [{'path': "~/vimwiki", 'syntax': 'markdown', 'ext': '.md'}]
        
        set statusline+=%{ObsessionStatus()}
        set statusline+=%#warningmsg#
        set statusline+=%{SyntasticStatuslineFlag()}
        set statusline+=%*
        
        let g:syntastic_always_populate_loc_list = 1
        let g:syntastic_auto_loc_list = 1
        let g:syntastic_check_on_open = 1
        let g:syntastic_check_on_wq = 0
endif

" tabs settings
set tabstop=8
set expandtab
set shiftwidth=4
set autoindent
set smartindent
set cindent " does proper thing for C programs, apparently.
set pastetoggle=<f5> " stop stupid autoindent when pasting
" end tabs settings

let mapleader = ","

" Triger `autoread` when files changes on disk
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
