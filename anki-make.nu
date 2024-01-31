# anki-make.nu
# dependency: md2apkg

use std assert

def default-config [
  dir: path
] {
  {
    name: ($dir | path basename)
  }
}

export def main [
  ...dirs: glob
  --ignore-dollar (-p)
  --include-empty # not implemented yet
  --new (-n) # initialize
] {
  if $new {
    initialize $dirs
    return
  }

  let dirs = $dirs | each {|d| ls --directory $d} | flatten
  assert ($dirs | all {|col| $col.type == 'dir'})
  $dirs | get name | par-each {
    |dir|
    anki-make-once $dir --ignore-dollar=$ignore_dollar
  }
}

def anki-make-once [
  dir: path
  --ignore-dollar
] {
  let olddir = pwd
  cd $dir
  let config: record = try {
    open 'anki-make.yaml'
  } catch {
    default-config $dir
  }
  let tempfile = mktemp -t
  # two newlines just in case...
  ['# ' $config.name "\n\n"] | str join | save -a $tempfile
  # recursive under src/
  ls src/**/*.md | get name | each {
    |f|
    open -r $f
  } | str join "\n\n" | save -a $tempfile
  let ret = match $ignore_dollar {
    true => {
      (md2apkg
        --input $tempfile
        --output ($olddir | path join $"($dir).apkg") # use dirname as filename
        # --ignore-levels 3 # This just removes h3 sections
        --ignore-latex-dollar-syntax
        --deck-name $config.name)
    }
    false => {
      (md2apkg
        --input $tempfile
        --output ($olddir | path join $"($dir).apkg") # use dirname as filename
        --ignore-levels '3'
        --deck-name $config.name)
    }
  }
  rm $tempfile

  $ret
}

def anki-txt-to-apkg2md [file: path] {
  open -r $file | from tsv -c "#" -n | reject column3
  # have issue when printing, but will pipe correctly
  | update column2 {
    |c| $c.column2 | pandoc -f html -t gfm
  }
  | reduce -f "" {
    |it inc|
    ['##' $it.column1] | str join " "
    | [$inc $in $it.column2] | str join "\n\n"
  }
}

def initialize [dirs: list<string>] {
  $dirs | each {
    |dir|
    mkdir $dir
    cd $dir
    mkdir src
    {name: ($dir | path basename)} | to yaml | save anki-make.yaml
  }
}
