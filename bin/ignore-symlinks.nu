#!/usr/bin/env nu
# Rewrite this with pure nu in future

use std assert

# Rewritten. Function may vary.
export def main [] {
  let fn = ".gitignore"
  assert ($fn | path exists)
  let gitignore = open $fn | lines
  let sep = "## AUTO GENERATED SYMLINK IGNORE ##"
  if not $sep in $gitignore {
    $sep + "\n" | save -a $fn
  }
  ls **/* | where type == symlink | get name | each {
    |e|
    if not $e in $gitignore {
      $e + "\n" | save -a $fn
    }
  }
  null
}
