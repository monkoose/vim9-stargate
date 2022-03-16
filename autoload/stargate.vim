vim9script

import '../_import/workstation.vim' as ws
import '../_import/vim9000.vim' as vim
import '../_import/galaxies.vim'

g:stargate_ignorecase = get(g:, 'stargate_ignorecase', true)
g:stargate_limit = get(g:, 'stargate_limit', 300)
g:stargate_chars = get(g:, 'stargate_chars', 'fjdklshgaewiomc')->split('\zs')
g:stargate_name = get(g:, 'stargate_name', 'Human')
g:stargate_keymaps = get(g:, 'stargate_keymaps', {})

def Highlight()
  :highlight default StargateFocus guifg=#958c6a
  :highlight default StargateDesaturate guifg=#49423f
  :highlight default StargateError guifg=#d35b4b
  :highlight default StargateLabels guifg=#caa247 guibg=#171e2c
  :highlight default StargateErrorLabels guifg=#caa247 guibg=#551414
  :highlight default StargateMain guifg=#f2119c gui=bold cterm=bold
  :highlight default StargateSecondary guifg=#11eb9c gui=bold cterm=bold
  :highlight default StargateShip guifg=#111111 guibg=#caa247
  :highlight default StargateVIM9000 guifg=#111111 guibg=#b2809f gui=bold cterm=bold
  :highlight default StargateMessage guifg=#a5b844
  :highlight default StargateErrorMessage guifg=#e36659
enddef

augroup ReapplyHighlight
  autocmd!
  autocmd ColorScheme * call Highlight()
augroup END

Highlight()

if empty(prop_type_get('sg_focus'))
  prop_type_add('sg_focus', { highlight: 'StargateFocus', combine: false, priority: 1000})
endif

if empty(prop_type_get('sg_desaturate'))
  prop_type_add('sg_desaturate', { highlight: 'StargateDesaturate', combine: false, priority: 1005})
endif

if empty(prop_type_get('sg_error'))
  prop_type_add('sg_error', { highlight: 'StargateError', combine: false, priority: 1010 })
endif

if empty(prop_type_get('sg_ship'))
  prop_type_add('sg_ship', { highlight: 'StargateShip', combine: false, priority: 1015})
endif

# Precreate hidden popup windows for stargates hints
ws.CreatePopups()

export def OKvim(mode: any)
    vim.OkVIM(mode)
enddef

export def Galaxy()
    galaxies.ChangeGalaxy(true)
enddef

# Remove this after some time
export def ErrorMsg(function_name: string)
    echohl WarningMsg
    echo "Since vim9 doesn't have stable API yet changes to config are required"
    echo "Read "
    echohl String
    echon ":h stargate-error"
    echohl WarningMsg
    echon " to learn how to fix this issue"
    echohl None

    echoerr "E117: Unknown function: " .. function_name
enddef

const legacy_definitions =<< trim VIM
    function stargate#ok_vim(mode) abort
        call stargate#ErrorMsg("stargate#ok_vim")
    endfunction

    function stargate#galaxy() abort
        call stargate#ErrorMsg("stargate#galaxy")
    endfunction
VIM
legacy execute join(s:legacy_definitions, "\n")
