# vim9-stargate

![Stargate Presentation](https://raw.githubusercontent.com/monkoose/stargate-images/main/stargate_presentation.gif)

You can think of **stargate** as simplified modern alternative to
[easymotion](https://github.com/easymotion/vim-easymotion) for vim 8.2+. It
uses popups windows to show hints, so it will not modify the content of your
buffer, because of that used linter plugins will not get mad. It is created for
just one purpose - jump to any visible character in the current window without
thinking of where your cursor is. Stargate do not support all the features of
easymotion and will never do.

## Motivation

There are few things that I wanted easymotion to have. First is already
mentioned problem with linter plugins, and the second is that using non-English
language in your code/text will make harder to navigate in a buffer with
easymotion, because to jump to non-English character require switching your
locale multiple times (first to choose this character, and second to go back to
English and select a hint). Look at `g:stargate_keymaps` for that.

## Usage

Stargate by default doesn't add any command or mapping. So at the same time it
doesn't add anything to vim startup time. To use it, just need to create a
mapping and call stargate function, like so
```
noremap <leader>f <Cmd>call stargate#ok_vim()<CR>
```
Notice that it is `noremap` and not `nnoremap` so stargate will work, not only
in normal mode but also in visual and operator-pending modes. Do not use `:call
...`, `<Cmd>call ...` is required, or stargate will behave not as you want it to.

To swap to a different window when stargate is enabled (but not in a hints
mode) just press `<C-w>`, so then you can choose window label to swap to it
(`space` to return into the current window). If for some reason you want to use
this feature outside of stargate itself you can map it like so
```
nnoremap <leader>w <Cmd>call stargate#galaxy()<CR>
```
And here we actually have `nnoremap` this time , because it makes no sense to
swap to another window in visual or operator-pending modes.

If you need another jump locations like easymotion jump to start of word, or
start of line etc. You can use `stargate#ok_vim()` function with just vim
pattern as argument.
```vim
" for the start of word
noremap <leader>w <Cmd>call stargate#ok_vim("\<")
" for the start of line
noremap <leader>l <Cmd>call stargate#ok_vim("\_^")
" for the end of word
noremap <leader>e <Cmd>call stargate#ok_vim("\>")
" for any of bracket, parentheses or curly
noremap <leader>[ <Cmd>call stargate#ok_vim("\[(){}[\\]]")<CR>
```
So possible jump locations are limited only by your knowledge of vim regexp.

## Configuration

### Options

| Variable                | Description                               | Default             |
|-------------------------|-------------------------------------------|---------------------|
| `g:stargate_ignorecase` | Ignore case of the search.                | `v:true`            |
| `g:stargate_limit`      | Maximum number of popups.<sup>1</sup>     | `300`               |
| `g:stargate_chars`      | Chars used for hints.                     | `'fjdklshgaewiomc'` |
| `g:stargate_name`       | How should VIM9000 call you.              | `'Human'`           |
| `g:stargate_keymaps`    | Dict of all possible keymaps.<sup>2</sup> | `{}`                |

**1** - This limit required, because spawn a lot of popups is slow in vim, so
we should limit it. You can increase it if you have found, that it sometimes
limits your search results, but for any practical sense 300 is enough.

**2** - As example for russian language it can look like this
```vim
let g:stargate_keymaps = {
      \ "~": "Ё",
      \ "Q": "Й", "W": "Ц", "E": "У", "R": "К", "T": "Е", "Y": "Н", "U": "Г", "I": "Ш", "O": "Щ", "P": "З", "{": "Х", "}": "Ъ",
      \  "A": "Ф", "S": "Ы", "D": "В", "F": "А", "G": "П", "H": "Р", "J": "О", "K": "Л", "L": "Д", ":": "Ж", '"': "Э",
      \   "Z": "Я", "X": "Ч", "C": "С", "V": "М", "B": "И", "N": "Т", "M": "Ь", "<": "Б", ">": "Ю",
      \ "`": "ё",
      \ "q": "й", "w": "ц", "e": "у", "r": "к", "t": "е", "y": "н", "u": "г", "i": "ш", "o": "щ", "p": "з", "[": "х", "]": "ъ",
      \  "a": "ф", "s": "ы", "d": "в", "f": "а", "g": "п", "h": "р", "j": "о", "k": "л", "l": "д", ";": "ж", "'": "э",
      \   "z": "я", "x": "ч", "c": "с", "v": "м", "b": "и", "n": "т", "m": "ь", ",": "б", ".": "ю"
      \ }
```
You can add as many chars in a string as you want, and they all will be
searched for that dictionary key. As example to search for `t`, `е` (it's
russian е) and `ё` with only `t` search
```
let g:stargate_keymaps = { "t": "её" }
```
Or to jump to any of bracket, parentheses or curly bracket on `[` search
```
let g:stargate_keymaps = { "[": "[](){}" }
```

### Colors

Stargate provides some highlight groups that you can change to look good with
your colorscheme.

| Highlight group       | Description                                               |
|-----------------------|-----------------------------------------------------------|
| StargateFocus         | visible text of the current window when stargate invoked  |
| StargateDesaturate    | visible text when hints are enabled                       |
| StargateError         | text highlight when something goes wrong                  |
| StargateLabels        | window labels                                             |
| StargateErrorLabels   | window labels when something goes wrong                   |
| StargateMain          | main color of the hints                                   |
| StargateSecondary     | secondaty colors of the hints                             |
| StargateShip          | highlight for cursor position                             |
| StargateVIM9000       | color for VIM9000 name in the command line                |
| StargateMessage       | color of the standard message from VIM9000                |
| StargateErrorMessage  | color of the error message from VIM9000                   |

Defaults are
```vim
highlight default StargateFocus guifg=#958c6a
highlight default StargateDesaturate guifg=#49423f
highlight default StargateError guifg=#d35b4b
highlight default StargateLabels guifg=#caa247 guibg=#171e2c
highlight default StargateErrorLabels guifg=#caa247 guibg=#551414
highlight default StargateMain guifg=#f2119c gui=bold cterm=bold
highlight default StargateSecondary guifg=#11eb9c gui=bold cterm=bold
highlight default StargateShip guifg=#111111 guibg=#caa247
highlight default StargateVIM9000 guifg=#111111 guibg=#b2809f gui=bold cterm=bold
highlight default StargateMessage guifg=#a5b844
highlight default StargateErrorMessage guifg=#e36659
```

Remove `default` from this list and add any highlight group you want to change
into your vimrc.

## FAQ

- **What are this weird naming in the source code?**

  Just for fun
  [INTRODUCTION](https://github.com/monkoose/vim9-stargate/blob/main/INTRODUCTION.md)
  should explain it a little bit.

## TODO

- [ ] Add vim documentation
- [ ] Add tests
- [ ] Improve text grammar
