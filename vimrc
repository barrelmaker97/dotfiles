" .vimrc

"Plugins
call plug#begin()
Plug 'morhetz/gruvbox'
Plug 'keith/tmux.vim'
Plug 'itchyny/lightline.vim'
Plug 'tpope/vim-surround'
call plug#end()

"Changes for older Vim versions
if has("termguicolors")
	set termguicolors
else
	let g:gruvbox_termcolors=16
end

"Turn on cursorline for gvim
if has('gui')
  set cursorline
else
  set nocursorline
end

"Colorscheme
syntax enable
colorscheme gruvbox
set background=dark

"Lightline
set noshowmode
set laststatus=2
let g:lightline = { 'colorscheme': 'gruvbox' }

"Line numbers
set number

"Set tab size to 4
set tabstop=4
set shiftwidth=4

"Indentation
set autoindent
set smartindent

"Show whitespace
set list
set listchars=eol:»,tab:⁞\ ,trail:·
set showbreak=›››

"Split opening positions
set splitright
set splitbelow

"These are obnoxious
set noerrorbells
set visualbell

"Keep cursor relatively centered
set scrolloff=10

"Performance improvements
set lazyredraw
set ttyfast
set t_ut=

"Search
set incsearch
set ignorecase
set smartcase

"Read if file changes
set autoread

"Autocomplete
set wildmenu
set completeopt=menu,menuone
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

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
