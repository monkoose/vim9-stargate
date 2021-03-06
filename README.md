# vim9-stargate

![Stargate Presentation](https://raw.githubusercontent.com/monkoose/stargate-images/main/stargate_presentation.gif)

You can think of **stargate** as simplified modern alternative to
[easymotion](https://github.com/easymotion/vim-easymotion) for vim 8.2+. It
uses [popups windows](https://vimhelp.org/popup.txt.html) to show hints, so it
will not modify the content of your buffer and because of that linter plugins
will not get mad. It is created for just one purpose - jump to any visible
character in the current window without thinking of where your cursor is.
Stargate do not support all the features of easymotion and will never do.

## Motivation

There are few things that I miss in easymotion. First is already mentioned
problem with linter plugins, and the second one is that if you are using
non-English language in your code/text it makes harder to navigate in a buffer
with easymotion, because jumping to non-English character requires switching
your locale multiple times (first to choose this character, and second to go
back to English and select a hint). Options section for `g:stargate_keymaps`
describe how you can configure stargate to work with non-English text easier.

## Usage

Stargate by default doesn't add any command or mapping. But at the same time it
doesn't add anything to your vim startup time. So to use this plugin, you just
need to create a mapping and call stargate function, like so
```vim
" For 1 character to search before showing hints
noremap <leader>f <Cmd>call stargate#OKvim(1)<CR>
" For 2 consecutive characters to search
noremap <leader>F <Cmd>call stargate#OKvim(2)<CR>

" Instead of 1 or 2 you can use any higher number, but it isn't much practical
" and it is easier to use `/` or `?` for that
```
Notice that it is `noremap` (not `nnoremap`) this allows stargate to work not
only in normal mode, but also in visual and operator-pending modes. Do not use
`:call ...` (`<Cmd>call ...` is required) or plugin will behave not as you want
it to.

To change current window when stargate is enabled (but not in a hints
mode) just press `<C-w>`, so then you can choose window label to swap to it
(`space` to return to the current window). If for some reason you want to use
this feature outside of stargate plugin itself you can map provided function
to some convenient key
```vim
nnoremap <leader>w <Cmd>call stargate#Galaxy()<CR>
```
And here we actually use `nnoremap` this time , because it makes no sense to
swap to another window in visual or operator-pending modes.

To exit stargate at any moment press `<Esc>` or `<C-c>`.

If you want to use another jump locations like easymotion jump to start of a
word, or start of a line etc. You can use `stargate#OKvim()` with a string as
its only argument. This string is just some vim regexp.
```vim
" for the start of a word
noremap <leader>w <Cmd>call stargate#OKvim("\<")
" for the start of a line if it is visible
noremap <leader>l <Cmd>call stargate#OKvim("\_^")
" for the end of a word
noremap <leader>e <Cmd>call stargate#OKvim("\>")
" for any bracket, parentheses or curly bracket
noremap <leader>[ <Cmd>call stargate#OKvim("\[(){}[\\]]")<CR>
```
As you can see possible jump locations are limited only by your knowledge of
vim regexp.

## Configuration

### Options

| Variable                | Description                               | Default             |
|-------------------------|-------------------------------------------|---------------------|
| `g:stargate_ignorecase` | Ignore case of the search.                | `v:true`            |
| `g:stargate_limit`      | Maximum number of popups.<sup>1</sup>     | `300`               |
| `g:stargate_chars`      | Chars used for hints.                     | `'fjdklshgaewiomc'` |
| `g:stargate_name`       | How should VIM9000 call you.              | `'Human'`           |
| `g:stargate_keymaps`    | Dict of all possible keymaps.<sup>2</sup> | `{}`                |

**1** - This limit is required, because spawning a lot of popups is slow in vim. You
can increase it if you have found that it sometimes limits your search
results, but for any practical usage default value is enough.

**2** - It is a dictionary of the keys - characters that you press and values -
all characters you want to include in a search besides the key character. Both
are strings. As an example for Russian language it can look like this
```vim
let g:stargate_keymaps = {
      \ "~": "??",
      \ "Q": "??", "W": "??", "E": "??", "R": "??", "T": "??", "Y": "??", "U": "??", "I": "??", "O": "??", "P": "??", "{": "??", "}": "??",
      \  "A": "??", "S": "??", "D": "??", "F": "??", "G": "??", "H": "??", "J": "??", "K": "??", "L": "??", ":": "??", '"': "??",
      \   "Z": "??", "X": "??", "C": "??", "V": "??", "B": "??", "N": "??", "M": "??", "<": "??", ">": "??",
      \ "`": "??",
      \ "q": "??", "w": "??", "e": "??", "r": "??", "t": "??", "y": "??", "u": "??", "i": "??", "o": "??", "p": "??", "[": "??", "]": "??",
      \  "a": "??", "s": "??", "d": "??", "f": "??", "g": "??", "h": "??", "j": "??", "k": "??", "l": "??", ";": "??", "'": "??",
      \   "z": "??", "x": "??", "c": "??", "v": "??", "b": "??", "n": "??", "m": "??", ",": "??", ".": "??"
      \ }
```
You can add as many chars in a string as you want, and all of them will be
searched for that dictionary key. As example to search for `t`, `??` (it's
Russian ??) and `??` with only `t` search
```vim
let g:stargate_keymaps = { "t": "????" }
```
Or to jump to any of bracket, parentheses or curly bracket on `[` search
```vim
let g:stargate_keymaps = { "[": "[](){}" }
```

### Colors

Stargate provides some highlight groups that you can change to look good with
your color scheme.

| Highlight group       | Description                                               |
|-----------------------|-----------------------------------------------------------|
| StargateFocus         | visible text of the current window when stargate invoked  |
| StargateDesaturate    | visible text when hints are enabled                       |
| StargateError         | text highlight when something goes wrong                  |
| StargateLabels        | window labels                                             |
| StargateErrorLabels   | window labels when something goes wrong                   |
| StargateMain          | main color of the hints                                   |
| StargateSecondary     | secondary colors of the hints                             |
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

- [x] Add vim documentation
- [ ] Add tests
- [ ] Improve text grammar
