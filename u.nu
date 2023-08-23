# u.nu / utils.nu
# should be imported before use

use std assert

export def main [] {
  # default function
  assert-pwd
  link-scripts
  let msg = date now | format date %F | "Update " + $in
  gacp -m $msg
}

# Git add, commit.
export def gacp [
  --message (-m): string
] {
  assert-pwd
  git diff
  input -s "Press enter to continue, C-c to interrupt"
  git add .
  match ($message | describe) {
    'string' => {git commit -m $message}
    _ => {git commit}
  }
  git push
}
export alias g = gacp

# link executable scripts in `bin/`
export def link-scripts [] {
  assert-pwd
  cd bin
  chmod +x *
  ls | where type == file | get name | par-each { |e|
    ln -sf $e ($e | path parse | get stem)
  }
}
export alias l = link-scripts

export def ignore [] {ignore-symlinks}
export alias i = ignore

def assert-pwd [] {
  assert (ls -a | '.git' in $in.name)
}
