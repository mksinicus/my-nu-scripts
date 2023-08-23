#!/usr/bin/env nu

use std assert

alias edit = ^($env.EDITOR)
alias negate = collect {|x| not $x}
alias not-empty = collect {|x| $x | is-empty | negate}

# cfg.nu
# A script to manage application configs (a.k.a. dotfiles)
# Nushell has `config` and subcommands, but I think I shall take a step further
# And use a shorter name, of course.
export def-env main [
  app?: string@get-cfg-list
  --list (-l) # List tracked configs
  --edit (-e)
  --cd (-c) # cd to repo path and exit
  --gacp (-g) # git add, commit with timestamp, push
  --pr (-p) # pijul record
  --move (-m) # Move them here!
] {
  let span = (metadata $app).span
  const cfg_list = 'cfg-list.nu'
  # Get VCS path from $env, exit if there isn't one
  # "Hint: assign $env.CFG_REPO in env.nu"
  # Then cd there within a scope, so that main is not affected
  # The `def-env` is for certain flags to function
  assert --error-label {text: "Can only take one action at a time"} (
    ([($app | not-empty) $list $edit $cd $gacp $pr $move] | find true | length) == 1
  )

  let ret = do {
    cdrepo
    # Flag switches, mutual exclusive
    # Check flags and switch to corresponding modes,
    # since we won't be using subcommands
    if $list {
      open-cfgs
    }
  }
  export-env {
    if $edit {
      edit $cfg_list
    } else if $gacp {
      acp
    } else if $pr {
      pijul record
    } else if $move {
      move-here (open-cfgs)
    } else if ($app | not-empty) {
      edit-cfgs $app
    }
  }

  if $cd {
    cdrepo
  }

  # hide-env cfg_list # amigo, we're running a `def-env` command
  return $ret
}

# For autocomplete and print out
def get-cfg-list [] {
  # had to define it again before any subsequent call!
  const cfg_list = 'cfg-list.nu'
  cdrepo
  open-cfgs | columns
}

def open-cfgs [] {
  const cfg_list = 'cfg-list.nu'
  use $cfg_list
  cfg-list
  | transpose key value
  | update value {
    |col| $col.value | match ($in | describe) {
      'string' => {$col.value | path expand}
      'record<file: string, action: closure>' => {
        $col.value | get file | path expand
      }
    }
  }
  | transpose -rd
}

def-env edit-cfgs [cfg: string] {
  const cfg_list = 'cfg-list.nu'
  use $cfg_list
  cfg-list | get $cfg
  | match ($in | describe) {
    'string' => {edit $in}
    'record<file: string, action: closure>' => {
      # not sure why `do` removed `--keep-env`
      collect --keep-env $in.action
    }
  }
  return null
}

def acp [] {
  def break-acp [] {
    error make {
      msg: "Git add-commit interrupted."
    }
  }

  git diff
  match (input 'Changes should display above. Continue? (y/N)') {
    'y' => {}
    _ => {break-acp}
  }
  git add .
  git commit -m (date now | format date %F) -e # Force edit commit message
  git push
}

def move-here [cfgs] {
  $cfgs | transpose name path | par-each {
    |it|
    mkdir $it.name
    ln -f ($it.path | path expand) $"./($it.name)/"
  }
}

def-env cdrepo [] {
  cd $env.CFG_REPO
}
