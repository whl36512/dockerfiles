" ~/.config/nvim/init.vim

call plug#begin()
Plug 'preservim/nerdtree'
" Plug 'easymotion/vim-easymotion'
Plug 'rust-lang/rust.vim'
call plug#end()
" uncomment and run :PlugInstall for the first time
":PlugInstall

map <C-n> :NERDTreeToggle<CR>

set number
set autoindent
"set relativenumber
"
let g:rustfmt_autosave = 1
syntax on

"enable mouse support
set mouse=a

