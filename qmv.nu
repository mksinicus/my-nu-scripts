# qmv.nu
# Quickly renames files with your favorite text editor. 
# A reimplementation of renameutils `qmv`.
# Dependency: `vipe` from moreutils
# Known issues: filename can't contain linebreaks or tabs

use std assert

export def main [
  glob: string
  --yes (-y) # Continue without confirmation
] {
  let span = (metadata $glob).span
  let pristine = (
    ls -a $glob | 
    where type != dir | # Excluding directories
    get name | each {
      |x| {old: $x, new: $x}
    }
  )
  let renamed = (
    $pristine | to csv -n -s "\t" | vipe |
    str replace -r "\t+" "\t" | # remove extra tabs to avoid users' blunder
    from csv -n -s "\t" | rename old new
  )
  assert ($pristine != $renamed) "No filename changed, aborting"
  print $renamed -n
  input "Confirm the rename? (y/N) " | str downcase | if $in != 'y' {
    error make {
      msg: "Unconfirmed. Aborting."
    }
  } else {
    # a trick to avoid circular reference
    # in a pipe it seems to be lazy
    let new_renamed = $renamed 
      | filter {|col| $col.old != $col.new } # Remove unchanged
      | update old {|col| open -r $col.old} 
    $new_renamed
    | par-each {
      |x| $x.old | save -f $x.new
    }
  }
  return null
}
