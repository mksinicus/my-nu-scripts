# my filesystem operations (cp, mv, rm)
# that accepts pipe input just like powershell
# For the sake of compatibility I will use a different name, with a p- affix

use std assert

export def prm [] {
  let input = $in
  match ($input | describe) {
    $x if ($x | str starts-with 'table<name: string, type: string') => {
      $input | get name | each-rm-r
    }
    'list<string>' => {
      $input | each-rm-r
    }
    'string' => {
      rm -r $input
    }
    _ => {
      error make {msg: "Unrecognized input, should be a table, list, or string"}
    }
  }
  print "Removed:"
  $input
}

def each-rm-r [] {
  $in | each {|x| rm -r $x}
}

export def pmv [
  --to (-t): path # directory to move files to
] {
  let input = $in
  assert ($to != null)
  assert ($to | path expand | ls -D $in | $in.0.type == dir)
  match ($input | describe) {
    $x if ($x | str starts-with 'table<name: string, type: string') => {
      $input | get name | each-mv-f-to $to
    }
    'list<string>' => {
      $input | each-mv-f-to $to
    }
    'string' => {
      mv -f $input $to
    }
    _ => {
      error make {msg: "Unrecognized input, should be a table, list, or string"}
    }
  }
  print $"Moved to ($to):"
  $input
}

def each-mv-f-to [to: path] {
  $in | each {|x| mv -f $x $to}
}

export def pcp [
  --to (-t): path # directory to move files to
] {
  let input = $in
  assert ($to != null)
  assert ($to | path expand | ls -D $in | $in.0.type == dir)
  match ($input | describe) {
    $x if ($x | str starts-with 'table<name: string, type: string') => {
      $input | get name | each-cp-r-to $to
    }
    'list<string>' => {
      $input | each-cp-r-to $to
    }
    'string' => {
      cp -r $input $to
    }
    _ => {
      error make {msg: "Unrecognized input, should be a table, list, or string"}
    }
  }
  print $"Copied to ($to):"
  $input
}

def each-cp-r-to [to: path] {
  $in | each {|x| cp -r $x $to}
}

export def pcd-do [cls: closure] {
  let input = $in
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

def each-cd-do [cls: closure] {
  $in | each {
    |dir|
    cd $dir
    do $cls
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
