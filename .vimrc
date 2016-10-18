"Plugins
call plug#begin()
Plug 'morhetz/gruvbox'
Plug 'keith/tmux.vim'
Plug 'itchyny/lightline.vim'
call plug#end()

"Set up colorscheme
set termguicolors
syntax enable
colorscheme gruvbox
set background=dark

"Lightline changes
set laststatus=2
let g:lightline = { 'colorscheme': 'gruvbox' }

"Add line numbers
set number

"Set tab size to 4
set tabstop=4
set shiftwidth=4

"Use indentation of previous line
set autoindent

"Use intelligent indentation for C
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
