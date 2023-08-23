# renamer.nu

# Rename files in the current directory.
export def main [
  pattern: string
  new: string
  --hidden (-a) # Include hidden files
  --regex (-r) # Use regex
  --simulate (-s) # Dry-run
  # --save (-s) # Save renaming result to nuon
] {
  # Closures. Naive, won't work with globs, but fine here
  let __ls = (if $hidden {{|| ls -a}} else {{|| ls}})
  alias _ls = do $__ls
  let __replace = (if $regex {{|x y| str replace -ra $x $y}}
                   else {{|x y| str replace -a $x $y}})
  alias _replace = do $__replace
  let __find = (if $regex {{|x| find -r $x}} else {{|x| find $x}})
  alias _find = do $__find
  
  if $simulate {
    (ansi rb) + "NOTE: This is only a simulation!"
  }
  # Make `mv` verbose. And we process the output into a table.
  _ls | get name | _find $pattern | par-each {
    |e|
    let new = ($e | _replace $pattern $new)
    if not $simulate {
      mv $e $new
    }
    {moved: ($e | path expand), to: ($new | path expand)}
  } | sort-by moved |
  # if not $save {$in} else {$in | to nuon}
}
