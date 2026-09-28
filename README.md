# NERDTree Pretty Lines

A small extension for [NERDTree](https://github.com/preservim/nerdtree) that draws real tree connectors instead of plain indentation.

```text
 ├─ src/
 │  ├─ main.cpp
 │  ╰─ renderer.cpp
 ╰─ tests/
    ╰─ test.cpp
```

It only changes NERDTree's tree prefixes. File names, DevIcons, Git status flags, mappings, and the rest of NERDTree rendering remain untouched.

## Requirements

- Vim with UTF-8 support
- [preservim/nerdtree](https://github.com/preservim/nerdtree)
- A font containing the characters you configure (the defaults use standard Unicode box-drawing characters)

## Installation

### vim-plug

```vim
Plug 'preservim/nerdtree'
Plug 'msdoslite/nerdtree-pretty-lines'
```

Then run:

```vim
:PlugInstall
```

NERDTree is the only required dependency. If NERDTree is not loaded, Pretty Lines exits silently and changes nothing.

## Configuration

All settings are optional and should be defined before NERDTree is opened.

```vim
let g:NERDTreePrettyLinesVertical   = '│'
let g:NERDTreePrettyLinesBranch     = '├'
let g:NERDTreePrettyLinesLast       = '╰'
let g:NERDTreePrettyLinesHorizontal = '─'

let g:NERDTreePrettyLinesGap     = ''
let g:NERDTreePrettyLinesFilePad = '  '
```

For a traditional square last branch:

```vim
let g:NERDTreePrettyLinesLast = '└'
```

To add a space after each branch:

```vim
let g:NERDTreePrettyLinesGap = ' '
```

To disable the extension completely:

```vim
let g:NERDTreePrettyLinesEnabled = 0
```

## Notes

Pretty Lines disables NERDTree's single-child directory cascading because a compressed `foo/bar/baz/` line cannot be represented accurately by branch connectors.

The extension is intentionally small and does not manage NERDTree itself.

## Help

After installation:

```vim
:help nerdtree-pretty-lines
```
