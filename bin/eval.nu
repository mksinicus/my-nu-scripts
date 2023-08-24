#!/usr/bin/env nu
# eval.nu
# Tweaks eval for Nushell in an ugly way

# export const scriptfile = '/tmp/nushell.eval.temp.nu'
# export alias eval = collect --keep-env {|x: any|
#   assert ($scriptfile | path exists)
#   $x | save -f $scriptfile
#   source $scriptfile
# }

export def main [
  --edit (-e)
] {
  let nuscript = (if $edit {$in | vipe --suffix=nu} else $in)
  let scriptfile = (mktemp) + ".nu"
  [
    'alias old-print = print'
    'alias print = print -e'
    $nuscript
  ] | str join "\n" | save -f $scriptfile
  
  let ret = (nu --config $nu.config-path --env-config $nu.env-path
    -c $'let ret = source ($scriptfile); $ret | to nuon'
    | from nuon)
  rm $scriptfile
  print $ret
  # | match $in {
  #   $x if ($x | check-nuon) => {$x | from nuon}
  #   _ => {}
  # }
}

def check-nuon [] {
  let data = $in
  try {
    $data | from nuon
    true
  } catch {
    false
  }
}
