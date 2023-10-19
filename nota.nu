#!/usr/bin/env nu

use std assert

export-env {
  load-env {
    NOTA_PATH: ($env.HOME | path join NutstoreFiles SYNC archivo)
    NOTA_EXT: "dj"
  }
}

export def-env main [
  slug?: string
  --no-dir (-n)
  --open (-o)
  --cd (-c)
  --go-home (-g)
  --move (-m)
  --yesman (-y)
] {
  $env._yesman = $yesman
  let flags = [$cd $go_home $move]
  let no_dir = $no_dir | into int
  let open = $open | into int
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
      wrapped-main --no-dir $no_dir --open $open $slug
    }
  }
  if $cd {
    cd $slug
  }
  hide-env _yesman
}

def wrapped-main [
  slug: string
  --no-dir (-n): int
  --open (-o): int
] {
  let no_dir = $no_dir | into bool
  let open = $open | into bool
  let front = [
    '---'
    ({
      title: $slug
      author: null
      date: (date now | format date %+)
      public: false
      lang: null
      tags: []
    } | to yaml | str trim)
    '---'
    ''
  ] | str join "\n"
  # let ext = "dj"
  let main_file = ["index" $env.NOTA_EXT] | str join '.'

  if $no_dir {
    let main_file = [$slug $env.NOTA_EXT] | str join '.'
    if not $env._yesman {input -s $"Creating file (pwd | path relative-to $env.NOTA_PATH)/($main_file). Press RET to continue, C-c to abort"} 
    try {
      $front | save $main_file
    } catch {
      {match (if not $env._yesman {input "file exists. overwrite? (y/N) "} else {'y'}) {
        'y' => {
          $front | save -f $main_file
        }
        _ => {abort}
      }}
    }
    if $open {
      editor $main_file
    }
  } else {
    if not $env._yesman {input -s $"Creating dir (pwd | path relative-to $env.NOTA_PATH)/($slug). Press RET to continue, C-c to abort"} 
    mkdir $slug
    cd $slug
    try {
      # <https://github.com/nushell/nushell/issues/10044>
      # $front | save $main_file
      $front | save (pwd | path join $main_file)
    } catch {
      match (if not $env._yesman {input "file exists. overwrite? (y/N) "} else {'y'}) {
        'y' => {
          $front | save -f $main_file
        }
        _ => {abort}
      }
    }
    if $open {
      editor $main_file
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
