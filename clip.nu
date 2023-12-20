# Clip the stdin to the system clipboard.

use entity.nu
alias _entity = entity

# Old definition
# export def clip [] {
#   $in | into string | ansi strip | str trim -c "\n" | xclip -sel clip
# }

# export use std clip
# use std
use modules/system clip
export def main []: any -> nothing {
  $in | clip --silent --no-notify
}

export def entity [ent] {
  _entity $ent | main
}

alias core-path-expand = path expand
export def path [path?: path] {
  let path = if ($path | is-empty) {'.'} else {$path}
  $path | core-path-expand | main
}

alias core-date-now = date now
alias core-date-format = format date
export def date [
  format?: string
] {
  let format = if ($format | is-empty) {'%+'} else {$format}
  core-date-now | core-date-format $format | main
}
