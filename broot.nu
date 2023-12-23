
# Broot
export def --env br [
  --args (-a): string
] {
  let cmd_file = (^mktemp | str trim)
  if ($args | is-empty) {
    ^broot --outcmd $cmd_file
  } else {
    ^broot $args --outcmd $cmd_file
  }
  $env.cmd = ((open $cmd_file) | str trim)
  ^rm $cmd_file
  cd ($env.cmd | str replace "cd" "" | str trim)
}

