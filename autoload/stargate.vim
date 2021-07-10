vim9script

import { CreatePopups } from 'workstation.vim'
import { OkVIM } from 'vim9000.vim'
import { ChangeGalaxy } from 'galaxies.vim'

g:stargate_ignorecase = get(g:, 'stargate_ignorecase', true)
g:stargate_limit = get(g:, 'stargate_limit', 300)
g:stargate_chars = get(g:, 'stargate_chars', 'asdfghjklewiomc')->split('\zs')
g:stargate_name = get(g:, 'stargate_name', 'Human')
g:stargate_keymaps = get(g:, 'stargate_keymaps', {})
g:stargate_labels = expand('<sfile>:p:h:h') .. '/galaxy_labels'

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
  prop_type_add('sg_focus', { highlight: 'StargateFocus', combine: false, priority: 195})
endif

if empty(prop_type_get('sg_desaturate'))
  prop_type_add('sg_desaturate', { highlight: 'StargateDesaturate', combine: false, priority: 200})
endif

if empty(prop_type_get('sg_error'))
  prop_type_add('sg_error', { highlight: 'StargateError', combine: false, priority: 205 })
endif

if empty(prop_type_get('sg_ship'))
  prop_type_add('sg_ship', { highlight: 'StargateShip', combine: false, priority: 210})
endif

# Precreate hidden popup windows for stargates hints
CreatePopups()

def stargate#ok_vim(pattern = '')
  OkVIM(pattern)
enddef

def stargate#galaxy()
  ChangeGalaxy(true)
enddef
