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
set listchars=eol:»,tab:⁞\ ,trail:·
set showbreak=›››

"Split opening positions
set splitright
set splitbelow

"Highlight line cursor is on
set cursorline

"Disable background clearing
set t_ut=

"These are obnoxious
set noerrorbells
set visualbell

"Single character insertion
nnoremap <Space> i_<Esc>r

"Fingers are already there...
nnoremap <C-j> <C-d>
nnoremap <C-k> <C-u>
vnoremap <C-j> <C-d>
vnoremap <C-k> <C-u>

"Because shift is hard to let go of okay
command! Wq wq
command! WQ wq
command! W w
command! Q q
