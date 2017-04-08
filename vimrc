" .vimrc

"Plugins
call plug#begin()
Plug 'morhetz/gruvbox'
Plug 'keith/tmux.vim'
Plug 'itchyny/lightline.vim'
Plug 'tpope/vim-surround'
Plug 'airblade/vim-gitgutter'
Plug 'mhinz/vim-startify'
call plug#end()

"Changes for older Vim versions
if has("termguicolors")
	set termguicolors
else
	let g:gruvbox_termcolors=16
end

"GUI Options
if has('gui')
	set cursorline
	set guifont=Consolas:h14
	set guioptions=egmr
	set lines=40 columns=85
	set shell=C:\WINDOWS\system32\cmd.exe
else
	set nocursorline
end

"Colors
syntax enable
colorscheme gruvbox
set background=dark

"Encoding
set encoding=utf-8

"Lightline
set noshowmode
set laststatus=2
let g:lightline = { 'colorscheme': 'gruvbox' }

"GitGutter
set updatetime=250
let g:gitgutter_sign_added = '+'
let g:gitgutter_sign_removed = 'X'
let g:gitgutter_sign_modified = 'Δ'
let g:gitgutter_sign_modified_removed = 'ΔX'
highlight link GitGutterChange GruvboxYellowSign
highlight link GitGutterChangeDelete GruvboxYellowSign

"Startify
let g:startify_files_number = 8
let g:startify_fortune_use_unicode = 1
let g:startify_list_order = [
	\ ['   Recent files'], 'files',
	\ ['   Sessions:'], 'sessions',
	\ ['   Bookmarks:'], 'bookmarks',
	\ ['   Commands:'], 'commands',
	\ ]
let g:startify_bookmarks = [
	\ {'v': '~/_vimrc'},
	\ {'c': '~/.bashrc'}
	\ ]
function! s:filter_header(lines) abort
	let longest_line   = max(map(copy(a:lines), 'strwidth(v:val)'))
	let centered_lines = map(copy(a:lines),
		\ 'repeat(" ", (&columns / 2) - (longest_line / 2)) . v:val')
	return centered_lines
endfunction
let g:startify_custom_header = s:filter_header(startify#fortune#cowsay())
highlight link StartifyHeader PreProc
highlight link StartifySection Constant
highlight link StartifyNumber Type

"Line numbers
set number

"Tabs
set tabstop=4
set shiftwidth=4

"Indentation
set autoindent
set smartindent

"Fix backspace
set backspace=2

"Whitespace
set list
set listchars=eol:»,tab:\|\ ,trail:·
set showbreak=›››

"Split opening positions
set splitright
set splitbelow
autocmd FileType help wincmd L

"Remove error bells
set noerrorbells visualbell t_vb=
autocmd GUIEnter * set visualbell t_vb=

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

"Filetypes
autocmd FileType hlasm set expandtab tabstop=3 shiftwidth=3
