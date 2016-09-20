set nowrap
set number
set background=dark

let g:python_host_prog = '__PYTHON2__'
let g:python3_host_prog = '__PYTHON3__'

" Plugins
"if empty(globpath(&rtp, 'autoload/plug.vim'))
"  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
"  autocmd VimEnter * PlugInstall
"endif

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

" Puppet
Plug 'rodjek/vim-puppet'
Plug 'godlygeek/tabular'

" SaltStack
Plug 'saltstack/salt-vim'

" LaTeX
Plug 'LaTeX-Box-Team/LaTeX-Box'

" Go
Plug 'fatih/vim-go'
Plug 'zchee/deoplete-go'

" Javascript
Plug 'pangloss/vim-javascript'

" Generic
Plug 'Shougo/deoplete.vim'
Plug 'Konfekt/FastFold'
Plug 'kien/ctrlp.vim'
Plug 'airblade/vim-rooter'
Plug 'ervandew/supertab'
Plug 'benekastah/neomake'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'

call plug#end()

" Strip trailing whitespace (and save cursor position) when saving files
fun! <SID>StripTrailingWhitespaces()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfun
autocmd BufWritePre * :call <SID>StripTrailingWhitespaces()
