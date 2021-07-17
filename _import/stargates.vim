vim9script

import {
  LabelLists,
  OrbitalArc,
  TransformPattern,
  CreatePopups,
  OrbitsWithoutBlackmatter
  } from "./workstation.vim"


def Desaturate()
  prop_add(g:stargate_near, 1, { end_lnum: g:stargate_distant, end_col: 5000, type: 'sg_desaturate' })
enddef


def Designations(length: number): list<string>
  const ds = LabelLists(g:stargate_chars, length)

  # remove unwanted labels from start and end of the label list
  var slice = ds.labels[ds.start_row : ds.end_row]
  const start = slice->remove(0)[ds.start_col :]
  const end = slice->insert(start)->remove(-1)[: ds.end_col]
  slice->add(end)

  # shuffle designations
  var dss = []
  for i in range(ds.len)
    for j in range(len(slice))
      const label = slice[j]->get(i, '')
      if !!label
        dss->add(label)
      endif
    endfor
  endfor

  return dss
enddef


def OrbitalStars(pattern: string, flags: string, orbit: number): list<list<number>>
  cursor(orbit, 1)
  var stars = []
  var star = searchpos(pattern, flags, orbit)
  while !!star[0]
    stars->add(star)
    const first = '\%>' .. star[1] .. 'c'
    star = searchpos(first .. pattern, flags, orbit)
  endwhile
  return stars
enddef


def CollectStars(orbits: list<number>, cur_loc: list<number>, pat: string): list<list<number>>
  var stars = []
  for orbit in orbits
    var orbital_stars = OrbitalStars(pat, 'Wnc', orbit)
    if orbit == cur_loc[0]
      for i in range(len(orbital_stars))
        if orbital_stars[i][1] == cur_loc[1]
          orbital_stars->remove(i)
          break
        endif
      endfor
    endif
    stars->add(orbital_stars)
  endfor
  return stars->flattennew(1)
enddef


def GalaxyStars(pattern: string): list<list<number>>
  const view = winsaveview()

  const arc = OrbitalArc()
  var degrees = {first: '', last: ''}
  if !&wrap
    degrees.first = '\%>' .. (arc.first - 1) .. 'v'
    degrees.last = '\%<' .. (arc.last + 1) .. 'v'
  endif

  const pat = degrees.first .. degrees.last .. pattern
  const cur_loc = [view.lnum, view.col + 1]
  const stars = OrbitsWithoutBlackmatter(g:stargate_near, g:stargate_distant)
                  ->CollectStars(cur_loc, pat)

  winrestview(view)
  return stars
enddef


export def GetDestinations(pattern: string): dict<any>
  const destinations = pattern->TransformPattern()->GalaxyStars()
  const length = len(destinations)

  var stargates: dict<any>
  if length == 0
    stargates = {}
  elseif length == 1
    stargates = {jump: {orbit: destinations[0][0], degree: destinations[0][1]}}
  elseif length > g:stargate_limit
    :redraw
    :echoerr "stargate: too much popups to show - " .. length
    stargates = {}
  else
    Desaturate()
    stargates = destinations->ShowStargates()
  endif

  return stargates
enddef


def ChooseColor(prev: dict<any>, orbit: number, degree: number): string
  if orbit == prev.orbit
       && prev.len >= degree - prev.degree
       && prev.color == 'StargateMain'
    return 'StargateSecondary'
  endif
  return 'StargateMain'
enddef


def ShowStargates(destinations: list<list<number>>): dict<any>
  const length = len(destinations)
  const names = Designations(length)
  var prev = { orbit: -1, degree: -1, len: 0, color: 'StargateMain' }
  var stargates: dict<any>

  # Check if some outside force closed some of stargate popups
  # mostly for popup_clear(), will fail on some manual popup_remove(id)
   if empty(popup_getpos(g:stargate_popups[g:stargate_chars[0]]))
     for id in values(g:stargate_popups)
       popup_close(id)
     endfor
     CreatePopups()
   endif

  for i in range(length)
    const name = names[i]
    const orbit = destinations[i][0]
    const degree = destinations[i][1]
    const id = g:stargate_popups[name]
    const color = ChooseColor(prev, orbit, degree)
    const scr_pos = screenpos(0, orbit, degree)
    const zindex = 100 + i
    popup_move(id, { line: scr_pos.row, col: scr_pos.col })
    popup_setoptions(id, { highlight: color, zindex: zindex })
    popup_show(id)
    stargates[name] = { id: id, orbit: orbit, degree: degree, color: color, zindex: zindex }
    prev = { orbit: orbit, degree: degree, len: len(name), color: color }
  endfor

  return stargates
enddef