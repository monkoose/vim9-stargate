vim9script

import './stargates.vim' as sg
import './galaxies.vim'
import './messages.vim' as msg
import './workstation.vim' as ws

var start_mode: string
var is_visual: bool
var is_hlsearch: bool
const match_paren_enabled: bool = exists(':DoMatchParen') == 2 ? true : false


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

  [g:stargate_near, g:stargate_distant] = ws.ReachableOrbits()

  is_hlsearch = false
  if !!v:hlsearch
    is_hlsearch = true
    setwinvar(0, '&hlsearch', 0)
  endif

  if match_paren_enabled
    :silent! call matchdelete(3)
  endif

  ws.ShowShip()
  ws.Focus()
  msg.StandardMessage(g:stargate_name .. ', choose a destination.')
enddef


def Goodbye()
  for v in values(g:stargate_popups)
    popup_hide(v)
  endfor
  prop_remove({ type: 'sg_error' }, g:stargate_near, g:stargate_distant)
  Saturate()
  ws.Unfocus()
  ws.HideShip()

  # rehighlight matched paren
  :doautocmd CursorMoved

  if is_hlsearch
    setwinvar(0, '&hlsearch', 1)
  endif

  if is_visual
    :execute 'normal! ' .. start_mode .. '`<o'
  endif
enddef


export def OkVIM(mode: any)
  try
    Greetings()
    var destinations: dict<any>
    if type(mode) == v:t_number
      g:stargate_mode = mode
      destinations = ChooseDestinations(mode)
    else
      g:stargate_mode = 0
      destinations = sg.GetDestinations(mode)
    endif
    if !empty(destinations)
      UseStargate(destinations)
    endif
  catch
    :echom v:exception
  finally
    Goodbye()
  endtry
enddef


def ShowFiltered(stargates: dict<any>)
  for [label, stargate] in items(stargates)
    const id = g:stargate_popups[label]
    const scr_pos = screenpos(0, stargate.orbit, stargate.degree)
    popup_move(id, { line: scr_pos.row, col: scr_pos.col })
    popup_setoptions(id, { highlight: stargate.color, zindex: stargate.zindex })
    popup_show(id)
    stargates[label].id = id
  endfor
enddef


def UseStargate(destinations: dict<any>)
  var nr: number
  var err: bool
  var stargates = copy(destinations)
  msg.StandardMessage('Select a stargate for a jump.')
  while true
    var filtered = {}
    [nr, err] = ws.SafeGetChar()

    if err || nr == 27
      msg.BlankMessage()
      return
    endif

    const char = nr2char(nr)
    for [label, stargate] in items(stargates)
      if !match(label, char)
        const new_label = strcharpart(label, 1)
        filtered[new_label] = stargate
      endif
    endfor

    if empty(filtered)
      msg.Error('Wrong stargate, ' .. g:stargate_name .. '. Choose another one.')
    elseif len(filtered) == 1
      msg.BlankMessage()
      cursor(filtered[''].orbit, filtered[''].degree)
      return
    else
      HideLabels(stargates)
      ShowFiltered(filtered)
      stargates = copy(filtered)
      msg.StandardMessage('Select a stargate for a jump.')
    endif
  endwhile
enddef


def ChooseDestinations(mode: number): dict<any>
  var nr: number
  var err: bool
  var to_galaxy: bool
  var destinations = {}
  while true
    var nrs = []
    for _ in range(mode)
      [nr, err] = ws.SafeGetChar()

      # 27 is <Esc>
      if err || nr == 27
        msg.BlankMessage()
        return {}
      endif

      # 23 is <C-w>
      if nr == 23
        to_galaxy = true
        break
      endif

      nrs->add(nr)
    endfor

    if to_galaxy
      to_galaxy = false
      # do not change window if in visual or operator-pending modes
      if is_visual || state()[0] == 'o'
        msg.Error('It is impossible to do now, ' .. g:stargate_name .. '.')
      elseif !galaxies.ChangeGalaxy(false)
        return {}
      endif
      # if current window after the jump is in terminal or insert modes - quit stargate
      if !match(mode(), '[ti]')
        msg.InfoMessage("stargate: can't work in terminal or insert mode.")
        return {}
      endif
      continue
    endif

    destinations = sg.GetDestinations(nrs
                                    ->mapnew((_, v) => nr2char(v))
                                    ->join(''))
    # destinations = sg.GetDestinations(nr2char(nr))
    if empty(destinations)
      msg.Error("We can't reach there, " .. g:stargate_name .. '.')
      continue
    elseif len(destinations) == 1
      msg.BlankMessage()
      cursor(destinations.jump.orbit, destinations.jump.degree)
      return {}
    end
    break
  endwhile

  return destinations
enddef
