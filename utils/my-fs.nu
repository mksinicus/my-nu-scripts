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
      $input | get name | each-cp-to $to
    }
    'list<string>' => {
      $input | each-cp-to $to
    }
    'string' => {
      cp $input $to
    }
    _ => {
      error make {msg: "Unrecognized input, should be a table, list, or string"}
    }
  }
}

def each-cp-to [to: path] {
  $in | each {|x| cp $x $to}
}

