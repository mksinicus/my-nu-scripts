# lsr
export def lsr [
  path?: directory
  --all (-a)
  --long (-l)
] {
  alias ls = ls --all=$all --long=$long
  # let _ls = (if $all and $long {{|x| ls -la $x}} else 
  #           if $all {{|x| ls -a $x}} else
  #           if $long {{|x| ls -l $x}} else
  #           {{|x| ls $x}})
  
  if $path == null {
    ls `**/*`
  } else {
    ls (($path | path expand) + '/**/*')
    | update name {
      |col|
      $col.name | path relative-to (pwd)
    }
  }
}

# ls-visual
export def lsv [
  path: glob = "."
  --all (-a) # Show hidden files
  --long (-l) # Get all available columns for each entry
  --full-paths (-f) # Display paths as absolute paths
  --du (-d) # Display the apparent directory size ("disk usage") in place of the directory metadata size
] {
  # Handle the flags, ugly!
  alias ls = do (
    if $all and $long and $full_paths {{|x| ls -alf $x}}
    else if $all and $long {{|x| ls -la $x}}
    else if $all and $full_paths {{|x| ls -af $x}}
    else if $long and $full_paths {{|x| ls -lf $x}}
    else if $all {{|x| ls -a $x}}
    else if $long {{|x| ls -l $x}}
    else if $full_paths {{|x| ls -f $x}}
    # else if $du {{|x| ls -d $x}} # This is too much. It's pow(2, num_of_args)
    else {{|x| ls $x}}
  )
  # Finally, pass it to `explore`
  ls $path | explore
}

