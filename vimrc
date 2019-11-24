set nowrap
set number
set expandtab
set smarttab
set autoindent
set smartindent
colorscheme torte

let g:python_host_prog = '__PYTHON2__'
let g:python3_host_prog = '__PYTHON3__'
let g:C_Use_Tool_cmake = 'yes'

autocmd FileType html setlocal shiftwidth=2 tabstop=2
autocmd FileType java setlocal shiftwidth=4 tabstop=4
autocmd FileType c setlocal shiftwidth=2 tabstop=2
autocmd FileType go setlocal shiftwidth=4 tabstop=4
autocmd FileType js setlocal shiftwidth=2 tabstop=2
autocmd FileType v setlocal shiftwidth=2 tabstop=2

map <C-n> :NERDTreeToggle<CR>

" Plugins
if empty(globpath(&rtp, 'autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs \ http://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall
endif

call plug#begin('~/.vim/plugged')
" Lightweight Markup Languages
Plug 'vim-pandoc/vim-pandoc'
Plug 'vim-pandoc/vim-pandoc-syntax'

" Jinja2 Templates
Plug 'alanhamlett/vim-jinja', {'commit': 'cb0ad0c43f4e753d44d0a8599f2be65dd1f24f04'}

" Python
Plug 'hynek/vim-python-pep8-indent'
Plug 'davidhalter/jedi-vim'
Plug 'tmhedberg/SimpylFold'
let g:syntastic_python_checkers = ['pylint']

" Puppet
Plug 'rodjek/vim-puppet'
Plug 'godlygeek/tabular'

" SaltStack
Plug 'saltstack/salt-vim'

" LaTeX
Plug 'LaTeX-Box-Team/LaTeX-Box'

" C/C++
Plug 'vim-scripts/c.vim'

" Go
Plug 'fatih/vim-go'

" Javascript
Plug 'pangloss/vim-javascript'
Plug 'scrooloose/syntastic'
let g:syntastic_javascript_checkers = ['standard']

" Generic
Plug 'Konfekt/FastFold'
Plug 'kien/ctrlp.vim'
Plug 'ervandew/supertab'
Plug 'benekastah/neomake'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'vim-syntastic/syntastic'
Plug 'tpope/vim-repeat'
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'

call plug#end()

" Strip trailing whitespace (and save cursor position) when saving files
fun! <SID>StripTrailingWhitespaces()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfun
autocmd BufWritePre * :call <SID>StripTrailingWhitespaces()
