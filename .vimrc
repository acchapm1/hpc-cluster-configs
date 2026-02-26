" --------- Comments about this file ----------------- {{{
" used the default .vimrc as a start and added my own
" changes.  Alan Chapman
"  --------------------------------------------------- }}}
" Turns off vi-compatability
set nocompatible
" Changes mapleader from default of /
" mapleader is useful for setting custom modified commands.
let mapleader=' '       " space key is a good choice in normal mode as
let maplocalleader='\'
filetype on
syntax on

" turn on line numbers
set number
set tabstop=4
set shiftwidth=4
set autoindent
set nowrap
set showmode
set showmatch
set history=1000
set wildmenu
set wildmode=list:longest
set wildignore=*.docx,*.jpg,*.gif,*.png,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx
set viewoptions=folds,cursor
set sessionoptions=folds
set foldmethod=marker
set pastetoggle=<F3>

" Use a line cursor within insert mode and a block cursor everywhere else.
"
" Reference chart of values:
"   Ps = 0  -> blinking block.
"   Ps = 1  -> blinking block (default).
"   Ps = 2  -> steady block.
"   Ps = 3  -> blinking underline.
"   Ps = 4  -> steady underline.
"   Ps = 5  -> blinking bar (xterm).
"   Ps = 6  -> steady bar (xterm).
let &t_SI = "\e[3 q" "SI = Insert Mode
let &t_EI = "\e[5 q" "EI = Normal Mode
let &t_SR = "\e[1 q" "SR = Replace Mode

"" use filetype-based syntax highlighting, ftplugins, and indentation
syntax enable
filetype plugin indent on

"" Search settings
set incsearch  " search as characters are entered
set hlsearch   " highlight matches
set ignorecase " search is case insensitive...
set smartcase  " ...unless a capital is used

"" Turn off search highlighting from normal mode with leader+h
nmap <silent> <leader>h :silent :set invhlsearch<CR>

"" Show hidden tabs and trailing spaces
set listchars=tab:>-,trail:_,eol:$
nmap <silent> <leader>H :set nolist!<CR>

"" Show current command in status line
set showcmd

nmap <leader>; :
nmap <leader>w :w<CR>
nmap <leader>q :q<CR>
nmap <leader>x :x<CR>
nmap <leader>s :set invspell<CR>
nmap <leader>p :set paste<CR>
nmap <leader>u :set nopaste<CR>

let s:extfname = expand("%:e")

"" Plugins
call plug#begin('~/.vim/plugged')
Plug 'arcticicestudio/nord-vim'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'preservim/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'christoomey/vim-tmux-navigator'
call plug#end()

if has("mouse")
  set mouse-=a
  set mousehide
endif

if has("eval")
	  let is_bash=1
endif

let asyncfile = &backupdir . '/tmp'

" Shows tabs and trailing spaces
set listchars=tab:>-,trail:_,eol:$

"" Suggestions (uncomment for features)
source ~/.vim/optional/centralize-state.vim
source ~/.vim/optional/colors.vim
""source ~/.vim/optional/color-column.vim
""source ~/.vim/optional/group-closing.vim
source ~/.vim/optional/leaders.vim
source ~/.vim/optional/tex.vim
source ~/.vim/optional/markdown.vim
source ~/.vim/optional/visual-multi-cursors.vim
source ~/.vim/optional/omnicomplete.vim
source ~/.vim/optional/linebreaks.vim
source ~/.vim/optional/syntax-highlighting.vim
source ~/.vim/optional/ics.vim
