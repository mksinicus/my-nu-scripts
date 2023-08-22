#!/usr/bin/env nu

export-env {
  load-env {
    NOTA_PATH: ($env.HOME | path join NutstoreFiles SYNC archivo)
  }
}

export def-env main [
  slug?: string
  --cd (-c)
  --go-home (-g)
  --move (-m)
] {
  if $go_home {
    cd $env.NOTA_PATH
    return
  }

  match ($slug | describe) {
    'nothing' => {abort}
    _ => {
      wrapped-main $slug
    }
  }
  if $cd {
    cd $slug
  }
}

def wrapped-main [
  slug: directory
] {
  let front = $'---
title: "($slug)"
author: ""
date: (date now | date format %+)
public: false
lang: null
---

'
  let main_file = "index.dj"

  input -s $"Creating directory (pwd | path relative-to $env.NOTA_PATH)/($slug). Press RET to continue, C-c to abort" 
  mkdir $slug
  cd $slug
  try {
    # <https://github.com/nushell/nushell/issues/10044>
    # $front | save $main_file
    $front | save (pwd | path join $main_file)
  } catch {
    match (input "file exists. overwrite? (y/N) ") {
      'y' => {pwd}
      _ => {abort}
    }
  }
}

def abort [] {
  error make {
    msg: 'aborted.'
  }
}
