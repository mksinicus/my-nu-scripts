# my filesystem operations (cp, mv, rm)
# that accepts pipe input just like powershell
# For the sake of compatibility I will use a different name, with a p- affix

use std assert

export def eachfile [cls: closure]: any -> list {
  let input = $in
  let files = match ($input | describe) {
    'list<string>' => {
      $input
    }
    'string' => {
      [$input]
    }
    $x if ([name type size] | all {$in in ($input | columns)}) => {
      $input | get name
    }
    _ => {
      error make {msg: "Unrecognized input, should be a table, list, or string"}
    }
  }
  $files | each $cls
  return $files
}

export def prm [] {
  let input = $in
  $input | eachfile {|| rm -r $in}
  print -e "Removed:"
  $input
}

export def pmv [
  --to (-t): path # directory to move files to
] {
  let input = $in
  assert not ($to | is-empty)
  assert ($to | path type | $in == 'dir')
  $input | eachfile {|| mv -f $in $to}
  print -e $"Moved to ($to):"
  $input
}

export def pcp [
  --to (-t): path # directory to move files to
] {
  let input = $in
  assert not ($to | is-empty)
  assert ($to | path type | $in == 'dir')
  $input | eachfile {|| cp -r $in $to}
  print -e $"Copied to ($to):"
  $input
}

def each-cp-r-to [to: path] {
  $in | each {|x| cp -r $x $to}
}

export def pcd-do [cls: closure] {
  let input = $in
  def each-cd-do [cls: closure] {
    $in | each {
      |dir|
      cd $dir
      do $cls
    }
  }
  match ($input | describe) {
    $x if ($x | str starts-with 'table<name: string, type: string') => {
      $input | where type == dir | get name | each-cd-do $cls
    }
    'list<string>' => {
      $input | each-cd-do $cls
    }
    'string' => {
      $in | each-cd-do $cls
    }
    _ => {
      error make {msg: "Unrecognized input, should be a table, list, or string"}
    }
  }
}

# NOTE: Don't set url's type to 'path', because that makes nu autoexpand it
# based on PWD
export def file-open [url?: string]: any -> nothing {
  match [$in, $url] {
    [null, null] => {
      error make {msg: "Missing argument"}
    }
    [$x, null] => {
      assert (($x | describe) == string) "Type mismatch"
      ^open $x
    }
    [null, $x] => {
      ^open $x
    }
    [$x, $y] => {
      error make {msg: "Superfluous argument"}
    }
  }
}
export alias o = file-open
