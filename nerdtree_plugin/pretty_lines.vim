" NERDTree Pretty Lines
" Renders real tree connectors while leaving filenames, devicons and git
" status rendering to NERDTree and its plugins.
scriptencoding utf-8

if exists('g:loaded_nerdtree_pretty_lines')
    finish
endif

" Allow users to disable the extension explicitly.
if !get(g:, 'NERDTreePrettyLinesEnabled', 1)
    finish
endif

" NERDTree loads files from nerdtree_plugin/ after its core objects exist.
" If this file is sourced manually or too early, fail silently and leave no
" loaded flag behind, so NERDTree may load it normally later.
if !exists('g:NERDTreeFileNode') || !exists('g:NERDTreeDirNode') || !exists('g:NERDTreeUI')
    finish
endif

let g:loaded_nerdtree_pretty_lines = 1

" ---------------------------------------------------------------------------
" Configuration
" ---------------------------------------------------------------------------
"
" Override any of these in vimrc.
"
" Rounded:
"   │
"   ├─
"   ╰─
"
" Square last branch:
"   let g:NERDTreePrettyLinesLast = '└'
"
" Extra space after a branch:
"   let g:NERDTreePrettyLinesGap = ' '
"
" File padding compensates for the open/close arrow shown on directories.
" Two spaces align files comfortably with NERDTree directory arrows.
"
let g:NERDTreePrettyLinesVertical   = get(g:, 'NERDTreePrettyLinesVertical',   '│')
let g:NERDTreePrettyLinesBranch     = get(g:, 'NERDTreePrettyLinesBranch',     '├')
let g:NERDTreePrettyLinesLast       = get(g:, 'NERDTreePrettyLinesLast',       '╰')
let g:NERDTreePrettyLinesHorizontal = get(g:, 'NERDTreePrettyLinesHorizontal', '─')
let g:NERDTreePrettyLinesGap        = get(g:, 'NERDTreePrettyLinesGap',        '')
let g:NERDTreePrettyLinesFilePad    = get(g:, 'NERDTreePrettyLinesFilePad',    '  ')

" A cascaded a/b/c directory has no meaningful place for branch connectors,
" so render one directory per tree level.
let g:NERDTreeCascadeSingleChildDir = 0
let g:NERDTreeCascadeOpenSingleChildDir = 0


" ---------------------------------------------------------------------------
" Prefix helpers
" ---------------------------------------------------------------------------

function! s:UnitWidth() abort
    let l:width = strdisplaywidth(
        \ g:NERDTreePrettyLinesBranch
        \ . g:NERDTreePrettyLinesHorizontal
        \ . g:NERDTreePrettyLinesGap)
    return max([1, l:width])
endfunction

function! s:VerticalSegment() abort
    let l:padding = s:UnitWidth() - strdisplaywidth(g:NERDTreePrettyLinesVertical)
    return g:NERDTreePrettyLinesVertical . repeat(' ', max([0, l:padding]))
endfunction

function! s:BlankSegment() abort
    return repeat(' ', s:UnitWidth())
endfunction

function! s:BranchSegment() abort
    return g:NERDTreePrettyLinesBranch
        \ . g:NERDTreePrettyLinesHorizontal
        \ . g:NERDTreePrettyLinesGap
endfunction

function! s:LastSegment() abort
    return g:NERDTreePrettyLinesLast
        \ . g:NERDTreePrettyLinesHorizontal
        \ . g:NERDTreePrettyLinesGap
endfunction

function! s:IsLastVisible(node) abort
    if empty(a:node.parent)
        return 1
    endif

    let l:siblings = a:node.parent.getVisibleChildren()
    return !empty(l:siblings) && l:siblings[-1].equals(a:node)
endfunction

function! s:PrettyPrefix(node) abort
    let l:prefix = ''
    let l:ancestors = []
    let l:parent = a:node.parent

    while !empty(l:parent) && !l:parent.isRoot()
        call insert(l:ancestors, l:parent, 0)
        let l:parent = l:parent.parent
    endwhile

    for l:ancestor in l:ancestors
        let l:prefix .= s:IsLastVisible(l:ancestor)
            \ ? s:BlankSegment()
            \ : s:VerticalSegment()
    endfor

    if !empty(a:node.parent)
        let l:prefix .= s:IsLastVisible(a:node)
            \ ? s:LastSegment()
            \ : s:BranchSegment()
    endif

    return l:prefix
endfunction


" ---------------------------------------------------------------------------
" Renderer
" ---------------------------------------------------------------------------

function! s:PrettyRenderToString(depth, drawText) dict abort
    let l:output = ''

    if a:drawText ==# 1
        let l:treeParts = s:PrettyPrefix(self)

        " Directories have an expand/collapse arrow in their display string.
        " Keep a small, configurable compensation for files.
        if !self.path.isDirectory && g:NERDTreeDirArrowExpandable !=# ''
            let l:treeParts .= g:NERDTreePrettyLinesFilePad
        endif

        let l:output .= l:treeParts . self.displayString() . "\n"
    endif

    if self.path.isDirectory ==# 1 && self.isOpen ==# 1
        let l:children = self.getVisibleChildren()

        if self.isCascadable() && a:depth > 0
            if !empty(l:children)
                let l:output .= l:children[0]._renderToString(a:depth, 0)
            endif
        elseif !empty(l:children)
            for l:child in l:children
                let l:output .= l:child._renderToString(a:depth + 1, 1)
            endfor
        endif
    endif

    return l:output
endfunction


" ---------------------------------------------------------------------------
" NERDTree depth parser
" ---------------------------------------------------------------------------
"
" Upstream NERDTree derives node depth from leading whitespace. Since the
" connectors are real buffer text, teach it to recognize our configurable
" tree segments.

function! s:PrettyIndentLevelFor(line) dict abort
    let l:text = a:line
    let l:level = 0

    let l:vertical = s:VerticalSegment()
    let l:blank    = s:BlankSegment()
    let l:branch   = s:BranchSegment()
    let l:last     = s:LastSegment()

    while stridx(l:text, l:vertical) ==# 0 || stridx(l:text, l:blank) ==# 0
        if stridx(l:text, l:vertical) ==# 0
            let l:text = strpart(l:text, strlen(l:vertical))
        else
            let l:text = strpart(l:text, strlen(l:blank))
        endif
        let l:level += 1
    endwhile

    if stridx(l:text, l:branch) ==# 0 || stridx(l:text, l:last) ==# 0
        let l:level += 1
    endif

    return l:level
endfunction

let g:NERDTreeFileNode._renderToString = function('<SID>PrettyRenderToString')
let g:NERDTreeDirNode._renderToString  = function('<SID>PrettyRenderToString')
let g:NERDTreeUI._indentLevelFor       = function('<SID>PrettyIndentLevelFor')


" ---------------------------------------------------------------------------
" Highlighting
" ---------------------------------------------------------------------------

function! s:PrettyLinesSyntax() abort
    silent! syntax clear NERDTreePrettyLine

    let l:chars =
        \ g:NERDTreePrettyLinesVertical
        \ . g:NERDTreePrettyLinesBranch
        \ . g:NERDTreePrettyLinesLast
        \ . g:NERDTreePrettyLinesHorizontal

    " Escape characters that have special meaning inside a Vim regexp class.
    let l:chars = escape(l:chars, ']\^-')

    execute 'syntax match NERDTreePrettyLine /[' . l:chars . ']/ containedin=ALL'
    highlight default link NERDTreePrettyLine NonText
endfunction

augroup nerdtree_pretty_lines
    autocmd!
    autocmd Syntax nerdtree call <SID>PrettyLinesSyntax()
augroup END
