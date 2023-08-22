# my utils 
# please use with global import
# only simple ones are stored in this file

export use my-math.nu *
export use my-path.nu *
export use my-sleep.nu *
export use my-fp.nu *
export use my-into/ *
export use my-dirs.nu *
export use my-url.nu *
export use my-ls.nu *

export use history-recent.nu *
export use move-recent.nu *

use std assert

# Simple closures
# P.ex. `ls | recent 10min`
export alias recent   = do {|x| where modified > (date now) - $x}
export alias parse-extension = do {insert extension {|c| $c.name | path parse | get extension}}
export alias dehuman  = do {update modified {|c| $c.modified | date format %+}}
export alias today    = do {date now | date format %F}
export alias datetime = do {date now | date format %+}
export alias hhmmss   = do {date now | date format %H:%M:%S}
export alias zq       = do {|x| zoxide query $x | str trim}
export alias negate   = collect {|x| not $x}

# cd and then ls
export def-env c [path: path] {
  cd $path
  ls -a
}

# mdcd
# mkdir then cd there
export def-env mdcd [dir: string] {
  # Had to use `def-env`! I didn't know.
  mkdir $dir
  cd $dir
}
export alias mc = mdcd

# touchmod.nu
export def touchmod [
  filename: string
  mode: string
] {
  let span_f = (metadata $filename).span
  let span_m = (metadata $mode).span
  assert (
    $mode
    | find -r '[ugoa]*([-+=]([rwxXst]*|[ugo]))+|[-+=][0-7]+'
    | is-empty
    | negate
  ) --error-label {
    start: $span_m.start
    end: $span_m.end
    text: ([$"chmod: invalid mode: '($mode)'"
             "try 'chmod --help' for more information."] | str join "\n")
  }
  touch $filename
  chmod $mode $filename
}

