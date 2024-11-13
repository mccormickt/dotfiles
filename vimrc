" Plugins - Installs vim-plug automatically if it doesn't exist
if empty(globpath(&rtp, 'autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall
endif

call plug#begin('~/.vim/plugged')

" Lightweight Markup Languages
Plug 'vim-pandoc/vim-pandoc'
Plug 'vim-pandoc/vim-pandoc-syntax'
Plug 'tpope/vim-markdown'
Plug 'jtratner/vim-flavored-markdown'

" Python
Plug 'davidhalter/jedi-vim'

" Rust
Plug 'rust-lang/rust.vim'
let g:rustfmt_autosave = 1

" LaTeX
Plug 'LaTeX-Box-Team/LaTeX-Box'

" C/C++
Plug 'vim-scripts/c.vim'
Plug 'benekastah/neomake'

" Go
Plug 'fatih/vim-go'
let g:go_fmt_command = "goimports"
let g:go_version_warning = 0

" HCL
Plug 'fatih/vim-hclfmt'
Plug 'hashivim/vim-terraform'
let g:terraform_align = 1
let g:terraform_fmt_on_save = 1

" Generic
Plug 'Konfekt/FastFold'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'godlygeek/tabular'
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'lifepillar/vim-solarized8'
Plug 'joshdick/onedark.vim'

call plug#end()

" Show matching braces, etc.
set showmatch

" Make it smart
set nowrap
set number
set ruler
set smartindent
set smarttab
set smartcase
set paste

" Default to soft tab, 4 spaces per tab
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4

" More history, mouse scrolling
set history=100
set mouse=a

" Nerdtree keybinding
map <C-n> :NERDTreeToggle<CR>

" Fix expansion mode
set wildmode=list:longest
set wildignore+=.git,.hg,.svn " Ignore version control repos
set wildignore+=*.6           " Ignore Go compiled files
set wildignore+=*.pyc         " Ignore Python compiled files
set wildignore+=*.rbc         " Ignore Rubinius compiled files
set wildignore+=*.swp         " Ignore vim backups
set wildignore+=*.o           " Ignore C/C++ object files
set wildignore+=*.beam        " Ignore Erlang beam
set wildignore+=*.class       " Ignore Java class
set wildignore+=node_modules  " Ignore npm install directory
set wildignore+=*~            " Ignore backup files

" Set theme
set background=dark
colorscheme onedark

if (has("nvim"))
  "For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
  let $NVIM_TUI_ENABLE_TRUE_COLOR=1
endif
"For Neovim > 0.1.5 and Vim > patch 7.4.1799 < https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162 >
"Based on Vim patch 7.4.1770 (`guicolors` option) < https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd >
" < https://github.com/neovim/neovim/wiki/Following-HEAD#20160511 >
if (has("termguicolors"))
  set termguicolors
endif

" Disable soft tabbing for HTML/CSS/JS/YAML
 au BufNewFile,BufRead *.html setl noexpandtab
 au BufNewFile,BufRead *.css setl noexpandtab
 au BufNewFile,BufRead *.js setl noexpandtab
 au BufNewFile,BufRead *.yaml setl expandtab
 au BufNewFile,BufRead *.yml setl expandtab

" Detect the markdown type
augroup markdown
  au!
  au BufNewFile,BufRead *.md,*.markdown setlocal filetype=ghmarkdown
augroup END

" Strip trailing whitespace (and save cursor position) when saving files
fun! <SID>StripTrailingWhitespaces()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfun
autocmd BufWritePre * :call <SID>StripTrailingWhitespaces()
