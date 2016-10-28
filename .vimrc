" .vimrc

"Plugins
call plug#begin()
Plug 'morhetz/gruvbox'
Plug 'keith/tmux.vim'
Plug 'itchyny/lightline.vim'
call plug#end()

"Colorscheme
set termguicolors
syntax enable
colorscheme gruvbox
set background=dark

"Lightline
set laststatus=2
let g:lightline = { 'colorscheme': 'gruvbox' }

"Line numbers
set number

"Set tab size to 4
set tabstop=4
set shiftwidth=4

"Smart indentation
set autoindent
set smartindent

"Show whitespace characters
set list
set listchars=eol:»,tab:\|\ ,trail:_,extends:>,precedes:<,nbsp:~
set showbreak=>>>

"Split opening positions
set splitright
set splitbelow

"Highlight line cursor is on
set cursorline

"Disable background clearing
set t_ut=

"Single character insertion
nnoremap <Space> i_<Esc>r
