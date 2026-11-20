let g:rustfmt_autosave = 1

let g:go_fmt_command = "goimports"
let g:go_version_warning = 0

let g:terraform_align=1
let g:terraform_fmt_on_save=1

let g:syntastic_javascript_checkers = ['standard']

" Completion
let g:ale_linters = { 'rust': ['analyzer'] }
let g:ale_fixers = { 'rust': ['rustfmt', 'trim_whitespace', 'remove_trailing_lines'] }
set completeopt=menu,menuone,preview,noselect,noinsert
let g:ale_completion_enabled = 1
inoremap <expr><Tab> (pumvisible()?(empty(v:completed_item)?"\<C-n>":"\<C-y>"):"\<Tab>")
inoremap <expr><CR> (pumvisible()?(empty(v:completed_item)?"\<CR>\<CR>":"\<C-y>"):"\<CR>")

" Show matching braces, etc.
set showmatch

" Make it smart
set nowrap
set number
set ruler
set smartindent
set smarttab
set smartcase
"set autoindent
set paste

" Default to softab, 4 spaces per tab
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
  let $NVIM_TUI_ENABLE_TRUE_COLOR=1
endif

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
