# pijul-list
# Lists files tracked by pijul

# Remember: In wrting a script, use the longer name. Such is the common
# practice of PowerShell scripts.


export def "pj ls" [
  --long (-l) # Get all available columns for each entry
  --repository (-r): path # Set the repository where this command should run. Defaults to the first ancestor of the current directory that contains a `.pijul` directory
] {
  let __pjls = (if $repository != null
    {{|| ^pijul list --repository $repository}} else
    {{|| ^pijul list}}
  )
  alias pj-ls = do $__pjls
  let lines = (pj-ls | lines);
  let __ls = (if $long {{|x| ls -la $x}} else {{|x| ls -a $x}})
  alias _ls = do $__ls
  # I don't know how to implement `--repository` with this yet
  _ls **/* | where name in $lines
}

export def "pj chan" [] {
  # `pj channel` outputs in random order. We fix that.
  ^pijul channel | lines |
  each {
    |e|
    let now = ($e | str substring ..1) == '*'
    {
      now: ($e | str substring ..1),
      name: ($e | str substring 2.. | if $now {(ansi default_underline) + $in} else {$in})
    }
  } | sort-by "now" -r | reject "now"
  # | do {
  #   let list = $in
  #   let rep = ($in | get 0)
  #   $list | update name $'(ansi red_bold)($rep)'
  # }
}

def pj-ls-chans [] {
  ^pijul channel | lines | each {
    |e| $e | str substring '2,'
  }
}

export def "pj switch" [
  TO: string@pj-ls-chans
] {
  ^pijul channel switch $TO
}

export alias "pj s" = pj switch

def pj-ls-names [] {
  ^pijul list | lines
}

export def "pj rm" [
  PATHS: string@pj-ls-names
] {
  ^pijul remove $PATHS
}

def pj-log-ls [] {
  ^pijul log --hash-only | lines
}
