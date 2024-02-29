# u.nu / utils.nu
# should be imported before use

use std assert

export def main [] {
  # default function
  assert-pwd
  link-scripts
  ignore-symlinks
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
  ls | where type == file | get name | par-each {|e|
    ln -sf $e ($e | path parse | get stem)
  }
}
export alias l = link-scripts

export def ignore-symlinks [] {
  let filename = ".gitignore"
  assert ($filename | path exists)
  let ignore_list = open $filename | lines
  let separator = "## AUTO GENERATED SYMLINK IGNORE ##"
  if not ($separator in $ignore_list) {
    $separator + "\n" | save -a $filename
  }
  ls **/* | where type == symlink | get name | each {|symlink|
    if not ($symlink in $ignore_list) {
      $symlink + "\n" | save -a $filename
    }
  }
  null
}
export alias i = ignore-symlinks

def assert-pwd [] {
  assert (ls -a | '.git' in $in.name)
}
