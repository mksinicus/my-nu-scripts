# eval.nu
# Tweaks eval for Nushell in an ugly way
# Very helpful, if you want to pipe snippets from your favorite editor
# to be executed by Nushell.
export def main [
  --edit (-e)
]: string -> any {
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
  $ret
}