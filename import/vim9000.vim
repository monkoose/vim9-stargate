vim9script

import { GetDestinations } from 'stargates.vim'
import { ChangeGalaxy } from 'galaxies.vim'
import { StandardMessage, Error, BlankMessage } from 'messages.vim'
import { SafeGetChar,
         ReachableOrbits,
         Focus,
         Unfocus,
         ShowShip,
         HideShip } from 'workstation.vim'

var start_mode: string
var is_visual: bool


def ToggleMatchParen(cmd: string)
  if empty(getcmdwintype()) && exists(':DoMatchParen') == 2
    :execute cmd
  endif
enddef


def HideLabels(stargates: dict<any>)
  for v in values(stargates)
    popup_hide(v.id)
  endfor
enddef


def Saturate()
  prop_remove({ type: 'sg_desaturate' }, g:stargate_near, g:stargate_distant)
enddef


def Greetings()
  start_mode = mode()
  is_visual = start_mode != 'n'
  if is_visual
    :execute "normal! \<C-c>"
  endif
  :nohlsearch
  [g:stargate_near, g:stargate_distant] = ReachableOrbits()
  ToggleMatchParen('NoMatchParen')
  ShowShip()
  Focus()
  StandardMessage(g:stargate_name .. ', choose a destination.')
enddef


def Goodbye()
  BlankMessage()
  for v in values(g:stargate_popups)
    popup_hide(v)
  endfor
  Saturate()
  Unfocus()
  HideShip()
  ToggleMatchParen('DoMatchParen')
  if is_visual
    :execute 'normal! ' .. start_mode .. '`<o'
  endif
enddef


export def OkVIM(pattern: string)
  Greetings()
  var destinations: dict<any>
  if empty(pattern)
    destinations = ChooseDestinations()
  else
    destinations = GetDestinations(pattern)
  endif
  if !empty(destinations)
    UseStargate(destinations)
  endif
  Goodbye()
enddef


def ShowFiltered(stargates: dict<any>)
  for [label, stargate] in items(stargates)
    const id = g:stargate_popups[label]
    const scr_pos = screenpos(0, stargate.orbit, stargate.degree)
    popup_move(id, { line: scr_pos.row, col: scr_pos.col })
    popup_setoptions(id, { highlight: stargate.color, zindex: stargate.zindex })
    popup_show(id)
  endfor
enddef


def UseStargate(destinations: dict<any>)
  var nr: number
  var err: bool
  var stargates = copy(destinations)
  while true
    var filtered = {}
    StandardMessage('Select a stargate for a jump.')
    [nr, err] = SafeGetChar()

    if err || nr == 27
      return
    endif

    const char = nr2char(nr)
    for [label, stargate] in items(stargates)
      if !match(label, char)
        const new_label = label[1 :]
        filtered[new_label] = stargate
      endif
    endfor

    if empty(filtered)
      Error('Wrong stargate, ' .. g:stargate_name .. '. Choose another one.')
    elseif len(filtered) == 1
      cursor(filtered[''].orbit, filtered[''].degree)
      return
    else
      HideLabels(stargates)
      ShowFiltered(filtered)
      stargates = copy(filtered)
    endif
  endwhile
enddef


def ChooseDestinations(): dict<any>
  var nr: number
  var err: bool
  var destinations = {}
  while true
    [nr, err] = SafeGetChar()

    if err || nr == 27
      return {}
    endif

    if nr == 23
      # do not change window if in visual or operator-pending modes
      if is_visual || state()[0] == 'o'
        Error('It is impossible to do now, ' .. g:stargate_name .. '.')
      elseif !ChangeGalaxy(false)
        return {}
      endif
      continue
    endif

    destinations = GetDestinations(nr2char(nr))
    if empty(destinations)
      Error("We can't reach there, " .. g:stargate_name .. '.')
      continue
    elseif len(destinations) == 1
      cursor(destinations.jump.orbit, destinations.jump.degree)
      return {}
    end
    break
  endwhile

  return destinations
enddef
