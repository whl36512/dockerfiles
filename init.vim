" ~/.config/nvim/init.vim

call plug#begin()
Plug 'preservim/nerdtree'
call plug#end()
" uncomment and run :PlugInstall for the first time
":PlugInstall

map <C-n> :NERDTreeToggle<CR>

set number
set autoindent
"set relativenumber

