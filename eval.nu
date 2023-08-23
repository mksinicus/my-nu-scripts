# eval.nu
# Tweaks eval for Nushell in an ugly way

use std assert
# export const scriptfile = '/tmp/nushell.eval.temp.nu'
# export alias eval = collect --keep-env {|x: any|
#   assert ($scriptfile | path exists)
#   $x | save -f $scriptfile
#   source $scriptfile
# }

export def main [
  nuscript: string
]: nothing -> any {
  const scriptfile = '/tmp/nushell.eval.temp.nu'
  assert ($scriptfile | path exists)
  [
    'alias old-print = print'
    'alias print = print -e'
    $nuscript
  ] | str join "\n" | save -f $scriptfile
  
  (nu --config $nu.config-path --env-config $nu.env-path
  -c $'let ret = source ($scriptfile); $ret | to nuon')
  | from nuon
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
