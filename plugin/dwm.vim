"==============================================================================
"    Copyright: Copyright (C) 2012 Stanislas Polu
"               Permission is hereby granted to use and distribute this code,
"               with or without modifications, provided that this copyright
"               notice is copied with it. Like anything else that's free,
"               dwm.vim is provided *as is* and comes with no warranty of
"               any kind, either expressed or implied. In no event will the
"               copyright holder be liable for any damages resulting from
"               the use of this software.
" Name Of File: dwm.vim
"  Description: Dynamic Window Manager behaviour for Vim
"   Maintainer: Stanislas Polu (polu.stanislas at gmail dot com)
" Last Changed: Tuesday, 23 August 2012
"      Version: See g:dwm_version for version number.
"        Usage: This file should reside in the plugin directory and be
"               automatically sourced.
"
"               For more help see supplied documentation.
"      History: See supplied documentation.
"==============================================================================

" Exit quickly if already running
if exists("g:dwm_version") || &cp
  finish
endif

let g:dwm_version = "0.1.1"

" Check for Vim version 700 or greater {{{1
if v:version < 700
  echo "Sorry, dwm.vim ".g:dwm_version."\nONLY runs with Vim 7.0 and greater."
  finish
endif

command! -n=0 -bar DWMNew call s:DWM_New()
command! -n=0 -bar DWMClose call s:DWM_Close()
command! -n=0 -bar DWMFocus call s:DWM_Focus()
command! -n=0 -bar DWMFull call s:DWM_Full()
command! -n=0 -bar DWMBall call s:DWM_Ball()

" Script Array for storing Buffer order
let s:dwm_bufs = []

function! s:DWM_BufCount()
  let cnt = 0
  for nr in range(1,bufnr("$"))
    if buflisted(nr)
      let cnt += 1
    endif
  endfor
  return cnt
endfunction

function! s:DWM_SyncBufs()
  for nr in range(1,bufnr('$'))
    if buflisted(nr)
      if index(s:dwm_bufs,nr) == -1
        let s:dwm_bufs += [nr]
      endif
    endif
  endfor
  for r_idx in range(1,len(s:dwm_bufs))
    let idx = len(s:dwm_bufs)-r_idx
    if !(buflisted(s:dwm_bufs[idx]))
      " echo idx
      call remove(s:dwm_bufs,idx)
    endif
  endfor
  " echo s:dwm_bufs
endfunction

function! s:DWM_TopBuf(buffer)
  let b = a:buffer
  let idx = index(s:dwm_bufs,b)
  if idx != -1
    call remove(s:dwm_bufs,idx)
    call insert(s:dwm_bufs,b)
  endif
  " echo s:dwm_bufs
endfunction


function! s:DWM_Ball()
  call s:DWM_SyncBufs()
  exec 'sb ' . s:dwm_bufs[len(s:dwm_bufs)-1]
  on!
  call s:DWM_SyncBufs()
  if len(s:dwm_bufs) > 1
    for idx in range(1,len(s:dwm_bufs)-1)
      let r_idx = (len(s:dwm_bufs)-1) - idx
      exec 'topleft sb ' . s:dwm_bufs[r_idx]
    endfor
  endif
endfunction


function! s:DWM_Full ()
  exec 'sb ' .  bufnr('%')
  on!
endfunction

function! s:DWM_New ()
  call s:DWM_Ball()
  vert topleft new
  call s:DWM_SyncBufs()
  call s:DWM_TopBuf(bufnr('%'))
endfunction

function! s:DWM_Close()
  bd
  call s:DWM_Ball()
  if s:DWM_BufCount() > 1
    " we just called ball we are at the top buffer
    let cb = s:dwm_bufs[0]
    hide
    exec 'vert topleft sb ' . cb
  endif
endfunction

function! s:DWM_Focus()
  call s:DWM_TopBuf(bufnr('%'))
  call s:DWM_Ball()
  if s:DWM_BufCount() > 1
    " we just called ball we are at the top buffer
    let cb = s:dwm_bufs[0]
    hide
    exec 'vert topleft sb ' . cb
  endif
endfunction


if !exists('g:dwm_map_keys')
    let g:dwm_map_keys = 1
endif

if g:dwm_map_keys
    map <C-N> DMWNew
    map <C-C> DMWClose
    map <C-H> DMWFocus
    map <C-L> DMWFull
    " map <C-B> DMWBall
    map <C-J> <C-W>w
    map <C-K> <C-W>W
    map <C-B> :ls<CR>
endif
