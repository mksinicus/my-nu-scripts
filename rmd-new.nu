#!/usr/bin/env nu

export def main [
  --slidy (-s)
  --html (-w)
  --print (-p)
  --edit (-e)
  filename?: string
] {
  if $edit {
    hx ~/css/template/*
    return
  }
  let front = if $html {
    open -r ~/css/template/html.md
  } else if $print {
    open -r ~/css/template/print.md
  } else if $slidy {
    open -r ~/css/template/slidy.md
  } else {
    return "No format specified"
  }
  if ($filename == null) {
    echo $front
  } else {
    $front | save -r $filename
  }
}
