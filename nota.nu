#!/usr/bin/env nu

use std assert

export-env {
  load-env {
    NOTA_PATH: ($env.HOME | path join NutstoreFiles SYNC archivo)
  }
}

export def-env main [
  slug?: string
  --no-dir (-n)
  --cd (-c)
  --go-home (-g)
  --move (-m)
] {
  let flags = [$cd $go_home $move]
  let no_dir = $no_dir | into int
  assert ($flags | find true | length | $in <= 1)
  if $go_home {
    cd $env.NOTA_PATH
    return
  } else if $move {
    move-to-dir $slug
    return
  }

  match ($slug | describe) {
    'nothing' => {abort}
    _ => {
      wrapped-main --no-dir $no_dir $slug
    }
  }
  if $cd {
    cd $slug
  }
}

def wrapped-main [
  slug: string
  --no-dir (-n): int
] {
  let no_dir = $no_dir | into bool
  let front = [
    '---'
    ({
      title: $slug
      author: null
      date: (date now | date format %+)
      public: false
      lang: null
    } | to yaml | str trim)
    '---'
    ''
  ] | str join "\n"
  let ext = "dj"
  let main_file = ["index" $ext] | str join '.'

  if $no_dir {
    let main_file = [$slug $ext] | str join '.'
    input -s $"Creating directory (pwd | path relative-to $env.NOTA_PATH)/($main_file). Press RET to continue, C-c to abort" 
    try {
      $front | save (pwd | path join $main_file)
    } catch {
      match (input "file exists. overwrite? (y/N) ") {
        'y' => {
          $front | save -f (pwd | path join $main_file)
        }
        _ => {abort}
      }
    }
  } else {
    input -s $"Creating file (pwd | path relative-to $env.NOTA_PATH)/($slug). Press RET to continue, C-c to abort" 
    mkdir $slug
    cd $slug
    try {
      # <https://github.com/nushell/nushell/issues/10044>
      # $front | save $main_file
      $front | save (pwd | path join $main_file)
    } catch {
      match (input "file exists. overwrite? (y/N) ") {
        'y' => {
          $front | save -f (pwd | path join $main_file)
        }
        _ => {abort}
      }
    }
  }
}

def move-to-dir [slug] {
  ls | get name | path parse | where stem == $slug | par-each { |e|
    mkdir $slug
    # This assumes there is an extension. However, this can be dangerous.
    let old = [$e.stem $e.extension] | str join '.'
    let new = $slug | path join (['index' $e.extension] | str join '.')
    # Verbosely move them
    mv -v ($e.stem + '.' + $e.extension) ($slug | path join ('index.' + $e.extension))
  }
}

def abort [] {
  error make {
    msg: 'aborted.'
  }
}
