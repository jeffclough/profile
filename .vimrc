" Configuration file for vim

" Normally we use vim-extensions. If you want true vi-compatibility
" remove change the following statements
set nocompatible	" Use Vim defaults instead of 100% vi compatibility
set backspace=indent,eol,start	" more powerful backspacing

" Now we set some defaults for the editor 
set autoindent		" always set autoindenting on
set textwidth=0		" Don't wrap words by default
set nobackup		" Don't keep a backup file
set viminfo='20,\"50	" read/write a .viminfo file, don't store more than
			" 50 lines of registers
set history=500		" keep 500 lines of command line history
set ruler		" show the cursor position all the time

" Suffixes that get lower priority when doing tab completion for filenames.
" These are files we are not likely to want to edit or read.
set suffixes=.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc

" Set up autoindent to use spaces rather than tabs and to place tab stops
" at every two characters.
set tabstop=8
set softtabstop=2
set shiftwidth=2
set expandtab
" Show hard tabs, but only in Python files.
set listchars=tab:>_
autocmd Filetype python set list
autocmd Filetype rust set list

" Disable PEP-8 style enforcement of Python indenture.
let g:python_recommended_style=0
let g:rust_recommended_style=0

" Set up a formatlistpat that recognizes bullets as well as numbers. (I'm
" using 'silent' here because it looks not all builds of vim recognize
" formatlistpat, so this keeps those builds from complaining about it.)
"silent set formatlistpat "^\s*\d\+[\]:.)}\t ]\s*"
set formatlistpat=^\\s*\\d\\+\\.\\s\\+\\\\|^\\s*<\\d\\+>\\s\\+\\\\|^\\s*[a-zA-Z.]\\.\\s\\+\\\\|^\\s*[ivxIVX]\\+\\.\\s\\+

" See http://vimdoc.sourceforge.net/htmldoc/change.html#fo-table for
" formattingoptions options.
"
" Enable reformatting paragraphs in both regular text and comments.
" Enble recognition of numbered lists when reformatting.
" Disable everything else.
set formatoptions=tcqn

" Prevent J and gq from double spacing after a period.
set nojoinspaces

if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

autocmd Filetype java   setlocal ts=2 st=2 sw=2 noexpandtab
autocmd Filetype markdown setlocal ts=8 st=2 sw=2 expandtab
autocmd Filetype python setlocal ts=8 st=2 sw=2 expandtab
autocmd Filetype rust setlocal ts=8 st=2 sw=2 expandtab

" We know xterm-debian is a color terminal
" if &term =~ "xterm-debian" || &term =~ "xterm-xfree86"
if &term =~ "xterm" || &term =~ "vt220"
  set t_Co=16
  set t_Sf=[3%dm
  set t_Sb=[4%dm
endif

" Make p in Visual mode replace the selected text with the "" register.
vnoremap p <Esc>:let current_reg = @"<CR>gvdi<C-R>=current_reg<CR><Esc>

" Vim5 and later versions support syntax highlighting. Uncommenting the next
" line enables syntax highlighting by default.
au BufRead,BufNewFile *.go set filetype=go
syntax on
set background=dark

" Debian uses compressed helpfiles. We must inform vim that the main
" helpfiles is compressed. Other helpfiles are stated in the tags-file.
set helpfile=$VIMRUNTIME/doc/help.txt.gz

if has("autocmd")
 " Enabled file type detection
 " Use the default filetype settings. If you also want to load indent files
 " to automatically do language-dependent indenting add 'indent' as well.
 filetype plugin on

endif " has ("autocmd")

" Some Debian-specific things
augroup filetype
  au BufRead reportbug.*		set ft=mail
  au BufRead reportbug-*		set ft=mail
augroup END

" The following are commented out as they cause vim to behave a lot
" different from regular vi. They are highly recommended though.
set showcmd       " Show (partial) command in status line.
set showmatch     " Show matching brackets.
set noignorecase  " Do case insensitive matching
set incsearch     " Incremental search
set hlsearch      " Highlight all matches of a search
"set autowrite    " Automatically save before commands like :next and :make

" Set some custom highlighting colors.
hi Search     term=reverse    ctermfg=0 ctermbg=3   guifg=Black guibg=DarkYellow
hi Comment    term=bold       ctermfg=3             guifg=#80a0ff
hi Constant   term=underline  ctermfg=2             guifg=#ffa0a0
hi Identifier term=underline  ctermfg=6             guifg=#40ffff
hi PreProc    term=underline  ctermfg=12            guifg=#ff80ff
hi Special    term=bold       ctermfg=12            guifg=Orange
hi Statement  term=bold       ctermfg=15            gui=bold guifg=#ffff60
hi Type       term=underline  ctermfg=14            gui=bold guifg=#60ff60
