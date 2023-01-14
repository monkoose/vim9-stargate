vim9script

import '../import/stargate/workstation.vim' as ws
import '../import/stargate/vim9000.vim' as vim
import '../import/stargate/galaxies.vim'

g:stargate_ignorecase = get(g:, 'stargate_ignorecase', true)
g:stargate_limit = get(g:, 'stargate_limit', 300)
g:stargate_chars = get(g:, 'stargate_chars', 'fjdklshgaewiomc')->split('\zs')
g:stargate_name = get(g:, 'stargate_name', 'Human')
g:stargate_keymaps = get(g:, 'stargate_keymaps', {})


# Creates plugin highlights
def Highlight()
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
    highlight default link StargateVisual Visual
enddef


# Initialize highlights
Highlight()

# Apply highlights on a colorscheme change
augroup StargateReapplyHighlights
    autocmd!
    autocmd ColorScheme * Highlight()
augroup END

# Add plugin property types
for [name, hl, priority] in [
        ['sg_focus', 'StargateFocus', 1000],
        ['sg_desaturate', 'StargateDesaturate', 1001],
        ['sg_error', 'StargateError', 1002],
        ['sg_ship', 'StargateShip', 1003]]
    ws.AddPropType(name, hl, priority)
endfor

# Initialize hidden popup windows for stargates hints
ws.CreateLabelWindows()


# Public API functions
export def OKvim(mode: any)
    vim.OkVIM(mode)
enddef

export def Galaxy()
    galaxies.ChangeGalaxy(true)
enddef

# vim: sw=4
