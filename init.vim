" ~/.config/nvim/init.vim

call plug#begin()
Plug 'preservim/nerdtree'
" Plug 'easymotion/vim-easymotion'
Plug 'rust-lang/rust.vim'
Plug 'vim-syntastic/syntastic'
" tagbar requires universal ctag, which is not installed, yet
" Plug 'majutsushi/tagbar'
call plug#end()

" uncomment and run :PlugInstall for the first time
":PlugInstall


set number
set autoindent
"set relativenumber
let g:rustfmt_autosave = 1
syntax on

"enable mouse support
set mouse=a

"nmap <F8> :TagbarToggle<CR>
map <C-n> :NERDTreeToggle<CR>

