" .vimrc

call plug#begin()
" Font checking
Plug 'drmikehenry/vim-fontdetect'

" Colors
Plug 'gruvbox-community/gruvbox'

" Appearance
Plug 'itchyny/lightline.vim'
Plug 'mhinz/vim-startify'

" Git plugins
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'

" Syntax Highlighting
Plug 'octol/vim-cpp-enhanced-highlight'
Plug 'chr4/nginx.vim'

" Nerdtree
Plug 'scrooloose/nerdtree'
call plug#end()

" Changes for older Vim versions
if has("termguicolors")
	set termguicolors
else
	let g:gruvbox_termcolors=16
endif

" Set leader
let mapleader="\<Space>"

" GUI Options
if has('gui')
	set cursorline
	set guioptions=egmr
	set lines=42 columns=85
	if fontdetect#hasFontFamily('Consolas')
		let &guifont = 'Consolas:h14'
	else
		let &guifont = 'Monospace 12'
	endif
else
	set nocursorline
endif

" Change shell for Windows
if has('win32')
	set shell=C:\WINDOWS\system32\cmd.exe
endif

" Colors
syntax enable
colorscheme gruvbox
set background=dark

" Encoding
set encoding=utf-8

" Status line
set noshowmode
set laststatus=2

" Line numbers
set number

" Tabs
set tabstop=4
set shiftwidth=4

" Indentation
set autoindent
set smartindent

" Fix backspace
set backspace=2

" Whitespace
set list
set listchars=eol:»,tab:\|\ ,trail:·
set showbreak=›››

" Performance
set updatetime=250
set lazyredraw
set ttyfast
set t_ut=

" Search
set incsearch
set ignorecase
set smartcase

" Read if file changes
set autoread
set noswapfile

" Keep cursor relatively centered
set scrolloff=10

" Split opening positions
set splitright
set splitbelow

" Remove error bells
set noerrorbells visualbell t_vb=

" Autocomplete
set wildmenu
set completeopt=menu,menuone

" PLUGIN SETTINGS

" Lightline
let g:lightline = { 'colorscheme': 'gruvbox' }

" GitGutter
let g:gitgutter_sign_added = '+'
let g:gitgutter_sign_removed = 'X'
let g:gitgutter_sign_modified = 'Δ'
let g:gitgutter_sign_modified_removed = 'ΔX'
highlight link GitGutterChange GruvboxYellowSign
highlight link GitGutterChangeDelete GruvboxYellowSign

" Startify
let g:startify_files_number = 8
let g:startify_fortune_use_unicode = 1
let g:startify_list_order = [
	\ ['   Recent files'], 'files',
	\ ['   Sessions:'], 'sessions',
	\ ['   Bookmarks:'], 'bookmarks',
	\ ['   Commands:'], 'commands',
	\ ]
let g:startify_bookmarks = [
	\ {'f': $MYVIMRC},
	\ {'c': '~/.bashrc'}
	\ ]
let g:startify_commands = [
	\ {'v': 'version'},
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

" MAPPINGS

" Autocomplete remap
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" vim-fugitive
nnoremap <Leader>gb :Gblame<CR>
nnoremap <Leader>gs :Gstatus<CR>
nnoremap <Leader>gd :Gdiff<CR>
nnoremap <Leader>gc :Gcommit<CR>
nnoremap <Leader>gp :Gpush<CR>
nnoremap <Leader>gl :Glog<CR>:copen<CR>

" Easy escape
inoremap jk <Esc>

" Single character insertion
nnoremap <Leader><Space> i_<Esc>r

" Whitespace trimming
nnoremap <Leader>tw :call TrimWhitespace()<CR>

" NERDTree
nnoremap <Leader>nt :NERDTreeToggle<CR>

" Quick make
nnoremap <F5> :make!<CR>

" Fingers are already there...
nnoremap <C-j> <C-d>
nnoremap <C-k> <C-u>
vnoremap <C-j> <C-d>
vnoremap <C-k> <C-u>

" Because shift is hard to let go of okay
command! Wq wq
command! WQ wq
command! W w
command! Q q

" Easy config reload
command! Reload :so $MYVIMRC

" Autocommands
autocmd FileType hlasm set expandtab tabstop=3 shiftwidth=3
autocmd GUIEnter * set visualbell t_vb=
autocmd FileType help wincmd L

" Spell checking
autocmd FileType markdown setlocal spell
autocmd FileType gitcommit setlocal spell
autocmd FileType text setlocal spell

" Trim trailing whitespace
function! TrimWhitespace()
	  let l = line('.')
	  let c = col('.')
	  %s/\s\+$//e
	  call cursor(l, c)
endfunction
