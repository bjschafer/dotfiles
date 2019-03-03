packadd minpac

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

" Load the plugins right now. (optional)
packloadall

filetype plugin indent on
syntax enable

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
