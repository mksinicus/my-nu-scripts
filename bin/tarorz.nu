#!/usr/bin/env nu

# Very naive and incomplete. Forgive me for creating this.
def main [
  ...filenames: string
  --decode (-d)
  --out (-o): string = $"(basename $env.PWD | str trim).tar.orz"
  --non_silent (-n)
] {
  if $decode {
    for f in $filenames {
      orz decode (if not $non_silent {"-s"}) $f | tar -xf -
    }
  } else {
    let out = if ($out | parse "{name}.tar.orz" | length) == 0 {
      $"($out).tar.orz"
    } else { $out }
    if ($out | path exists) {
      rm $out
      echo "Previous archive removed"
    }
    let filenames = ($filenames | each {|it| $"`($it)`"})
    nu -c $"tar -cf - ($filenames | str collect ' ') 
          | orz encode (if not $non_silent {"-s"}) 
          | save --raw ($out)"
  }
}
