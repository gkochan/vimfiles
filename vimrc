"append bundles
call pathogen#runtime_prepend_subdirectories(expand('~/.vim/bundles'))
call pathogen#helptags()
" 
"Use Vim settings, rather then Vi settings (much better!).
"This must be first, because it changes other options as a side effect.
set nocompatible
"turn on line numbers
set nu
"set tags dir
set tags=./tmp/tags,/opt/ruby/lib;
"use ack instead of grep
set grepprg=ack
" remap vim leader from '\' to ','
let mapleader=","
"map next-search-result and previous-search-result for grep
map <C-p> :cn<CR>
map <C-n> :cp<CR>
"map to expand with and without splits another file in current directory
map <Leader>e :e <C-R>=expand("%:p:h") . '/'<CR>
"map <Leader>s :split <C-R>=expand("%:p:h") . '/'<CR>
"map <Leader>v :vnew <C-R>=expand("%:p:h") . '/'<CR>
"allow backspacing over everything in insert mode
set backspace=indent,eol,start
"turn off the blinking cursor in normal mode:
set gcr=n:blinkon0
"hide the toolbar:
set go-=T
"store lots of :cmdline history
set history=1000

set showcmd     "show incomplete cmds down the bottom
set showmode    "show current mode down the bottom

set incsearch   "find the next match as we type the search
set hlsearch    "hilight searches by default

set nowrap      "dont wrap lines
set linebreak   "wrap lines at convenient points

"statusline setup
set statusline=%f       "tail of the filename

set fileformat=unix
"display a warning if fileformat isnt unix
set statusline+=%#warningmsg#
set statusline+=%{&ff!='unix'?'['.&ff.']':''}
set statusline+=%*

"display a warning if file encoding isnt utf-8
set statusline+=%#warningmsg#
set statusline+=%{(&fenc!='utf-8'&&&fenc!='')?'['.&fenc.']':''}
set statusline+=%*

set statusline+=%h      "help file flag
set statusline+=%y      "filetype
set statusline+=%r      "read only flag
set statusline+=%m      "modified flag

"display a warning if &et is wrong, or we have mixed-indenting
set statusline+=%#error#
set statusline+=%{StatuslineTabWarning()}
set statusline+=%*

set statusline+=%{StatuslineTrailingSpaceWarning()}

set statusline+=%{StatuslineLongLineWarning()}

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

"display a warning if &paste is set
set statusline+=%#error#
set statusline+=%{&paste?'[paste]':''}
set statusline+=%*

set statusline+=%=      "left/right separator
set statusline+=%{StatuslineCurrentHighlight()}\ \ "current highlight
set statusline+=%c,     "cursor column
set statusline+=%l/%L   "cursor line/total lines
set statusline+=\ %P    "percent through file
set laststatus=2

"recalculate the trailing whitespace warning when idle, and after saving
autocmd cursorhold,bufwritepost * unlet! b:statusline_trailing_space_warning

"return '[\s]' if trailing white space is detected
"return '' otherwise
function! StatuslineTrailingSpaceWarning()
    if !exists("b:statusline_trailing_space_warning")
        if search('\s\+$', 'nw') != 0
            let b:statusline_trailing_space_warning = '[\s]'
        else
            let b:statusline_trailing_space_warning = ''
        endif
    endif
    return b:statusline_trailing_space_warning
endfunction


"return the syntax highlight group under the cursor ''
function! StatuslineCurrentHighlight()
    let name = synIDattr(synID(line('.'),col('.'),1),'name')
    if name == ''
        return ''
    else
        return '[' . name . ']'
    endif
endfunction

"recalculate the tab warning flag when idle and after writing
autocmd cursorhold,bufwritepost * unlet! b:statusline_tab_warning

"return '[&et]' if &et is set wrong
"return '[mixed-indenting]' if spaces and tabs are used to indent
"return an empty string if everything is fine
function! StatuslineTabWarning()
    if !exists("b:statusline_tab_warning")
        let tabs = search('^\t', 'nw') != 0
        let spaces = search('^ ', 'nw') != 0

        if tabs && spaces
            let b:statusline_tab_warning =  '[mixed-indenting]'
        elseif (spaces && !&et) || (tabs && &et)
            let b:statusline_tab_warning = '[&et]'
        else
            let b:statusline_tab_warning = ''
        endif
    endif
    return b:statusline_tab_warning
endfunction

"recalculate the long line warning when idle and after saving
autocmd cursorhold,bufwritepost * unlet! b:statusline_long_line_warning

"return a warning for "long lines" where "long" is either &textwidth or 80 (if
"no &textwidth is set)
"
"return '' if no long lines
"return '[#x,my,$z] if long lines are found, were x is the number of long
"lines, y is the median length of the long lines and z is the length of the
"longest line
function! StatuslineLongLineWarning()
    if !exists("b:statusline_long_line_warning")
        let long_line_lens = s:LongLines()

        if len(long_line_lens) > 0
            let b:statusline_long_line_warning = "[" .
                        \ '#' . len(long_line_lens) . "," .
                        \ 'm' . s:Median(long_line_lens) . "," .
                        \ '$' . max(long_line_lens) . "]"
        else
            let b:statusline_long_line_warning = ""
        endif
    endif
    return b:statusline_long_line_warning
endfunction

"return a list containing the lengths of the long lines in this buffer
function! s:LongLines()
    let threshold = (&tw ? &tw : 80)
    let spaces = repeat(" ", &ts)

    let long_line_lens = []

    let i = 1
    while i <= line("$")
        let len = strlen(substitute(getline(i), '\t', spaces, 'g'))
        if len > threshold
            call add(long_line_lens, len)
        endif
        let i += 1
    endwhile

    return long_line_lens
endfunction

"find the median of the given array of numbers
function! s:Median(nums)
    let nums = sort(a:nums)
    let l = len(nums)

    if l % 2 == 1
        let i = (l-1) / 2
        return nums[i]
    else
        return (nums[l/2] + nums[(l/2)-1]) / 2
    endif
endfunction
"indent settings
set shiftwidth=4
set softtabstop=4
set expandtab
set autoindent

" set foldmethod=syntax "fold based on indent - slows down macvim like a hell with large files
set foldnestmax=3       "deepest fold is 2 levels
set nofoldenable        "dont fold by default

set wildmode=list:longest   "make cmdline tab completion similar to bash
set wildmenu                "enable ctrl-n and ctrl-p to scroll thru matches
set wildignore=*.o,*.obj,*~ "stuff to ignore when tab completing

"display tabs and trailing spaces
set list
set listchars=tab:▷⋅,trail:⋅,nbsp:⋅

set formatoptions-=o "dont continue comments when pushing o/O

"vertical/horizontal scroll off settings
set scrolloff=3
set sidescrolloff=7
set sidescroll=1

"load ftplugins and indent files
filetype plugin on
filetype indent on

"turn on syntax highlighting
syntax on

"some stuff to get the mouse going in term
set mouse=a
set ttymouse=xterm2

"hide buffers when not displayed
set hidden

if has("gui_running")
    set guioptions=ac
    "tell the term has 256 colors
    set t_Co=256
    "fill the screen
    "set columns=999
    "set lines=999

    if has("gui_gnome")
        set term=gnome-256color
        colorscheme ir_black
    else
        colorscheme ir_black
        set guitablabel=%M%t
        "set lines=40
        "set columns=115
    endif
    if has("gui_mac") || has("gui_macvim")
        "macmenu &File.New\ Tab key=<nop>
        "map <D-t> <Plug>PeepOpen
        set guifont=Menlo:h15
        " maximize in fullscreen mode
        set fuopt=maxvert,maxhorz
        "window transparency
        set transparency=7
    endif
    if has("gui_win32") || has("gui_win32s")
        set guifont=Consolas:h12
        set enc=utf-8
    endif
endif

" execute current ruby file
map <D-r> :rubyf %<CR>
nmap <silent> <Leader>n :NERDTreeToggle<CR>

"map Rails plugin find model, controller, etc.
map <Leader>m :Rmodel 
map <Leader>c :Rcontroller 
map <Leader>v :Rview 

"map resizing windows in horizontal mode
map - <C-W>-
map + <C-W>+
"and vertical mode
map <M>- <C-W><
map <M>+ <C-W>>

"set current file path to the current bufer's file path
"change splits with TAB
map <M-Tab> <C-W><C-W>
map <M-S-Tab> <C-W>W

"NERDCommenter shortcuts
nmap \\           <Plug>NERDCommenterInvert
xmap \\           <Plug>NERDCommenterInvert

" Enable TAB indent and SHIFT-TAB unindent
vnoremap <silent> <TAB> >gv
vnoremap <silent> <S-TAB> <gv

"remove whitespaces shortcut
nnoremap <silent> <F5> :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar>:nohl<CR>:retab<CR>

"make <c-l> clear the highlight as well as redraw
nnoremap <C-L> :nohls<CR><C-L>
inoremap <C-L> <C-O>:nohls<CR>

"map to bufexplorer
nnoremap <C-B> :BufExplorer<cr>

"map to fuzzy finder text mate stylez
nnoremap <Leader>f :FufFile **/<CR>
nnoremap <Leader>l :FufLine<CR>
nnoremap <Leader>t :FufTag<CR>

"map Q to something useful
noremap Q gq

"make Y consistent with C and D
nnoremap Y y$

"mark syntax errors with :signs
let g:syntastic_enable_signs=1

"snipmate setup
source ~/.vim/bundles/snipmate/snippets/support_functions.vim
autocmd vimenter * call s:SetupSnippets()
function! s:SetupSnippets()

    "if we're in a rails env then read in the rails snippets
    if filereadable("./config/environment.rb")
        call ExtractSnips("~/.vim/bundles/snipmate/snippets/ruby-rails", "ruby")
        call ExtractSnips("~/.vim/bundles/snipmate/snippets/eruby-rails", "eruby")
    endif

    call ExtractSnips("~/.vim/bundles/snipmate/snippets/html", "eruby")
    call ExtractSnips("~/.vim/bundles/snipmate/snippets/html", "xhtml")
    call ExtractSnips("~/.vim/bundles/snipmate/snippets/html", "php")
endfunction

"visual search mappings
function! s:VSetSearch()
    let temp = @@
    norm! gvy
    let @/ = '\V' . substitute(escape(@@, '\'), '\n', '\\n', 'g')
    let @@ = temp
endfunction
vnoremap * :<C-u>call <SID>VSetSearch()<CR>//<CR>
vnoremap # :<C-u>call <SID>VSetSearch()<CR>??<CR>


"jump to last cursor position when opening a file
"dont do it when writing a commit log entry
autocmd BufReadPost * call SetCursorPosition()
function! SetCursorPosition()
    if &filetype !~ 'commit\c'
        if line("'\"") > 0 && line("'\"") <= line("$")
            exe "normal! g`\""
            normal! zz
        endif
    end
endfunction

"define :HighlightLongLines command to highlight the offending parts of
"lines that are longer than the specified length (defaulting to 80)
command! -nargs=? HighlightLongLines call s:HighlightLongLines('<args>')
function! s:HighlightLongLines(width)
    let targetWidth = a:width != '' ? a:width : 79
    if targetWidth > 0
        exec 'match Todo /\%>' . (targetWidth) . 'v/'
    else
        echomsg "Usage: HighlightLongLines [natural number]"
    endif
endfunction


au FileType xml exe ":silent 1,$!tidy --input-xml true --indent yes 2>/dev/null"


" Sessions ********************************************************************
" Creates a session
function! MakeSession()

 let b:sessiondir = $HOME . "/.vim/sessions" . getcwd()
 if (filewritable(b:sessiondir) != 2)
   exe 'silent !mkdir -p ' b:sessiondir
   redraw!
 endif
 let b:sessionfile = b:sessiondir . '/session.vim'
 exe "mksession! " . b:sessionfile

endfunction

" Updates a session, BUT ONLY IF IT ALREADY EXISTS
function! UpdateSession()

 let b:sessiondir = $HOME . "/.vim/sessions" . getcwd()
 let b:sessionfile = b:sessiondir . "/session.vim"
 if (filereadable(b:sessionfile))
   exe "mksession! " . b:sessionfile
   echo "updating session"
 endif

endfunction

" Loads a session if it exists
function! LoadSession()
 if argc() == 0
  let b:sessiondir = $HOME . "/.vim/sessions" . getcwd()
  let b:sessionfile = b:sessiondir . "/session.vim"
  if (filereadable(b:sessionfile))
    exe 'source ' b:sessionfile
  else
    echo "No session loaded."
  endif
 else
  let b:sessionfile = ""
  let b:sessiondir = ""
 endif
endfunction

au VimEnter * :call LoadSession()
au VimLeave * :call UpdateSession()
map <leader>ms :call MakeSession()<CR>
