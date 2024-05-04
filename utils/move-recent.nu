# .move-recent.nu

use recent.nu

export def mv-recent [
  glob: string # Filename glob provided to `ls`, file only (no dir nor symlink)
  dest: string # Destination
  duration: duration
  --save (-s) # Save moving result to nuon
] {
  let glob_span = (metadata $glob).span
  let duration_span = (metadata $duration).span

  ls ($glob | into glob)
  | if ($in | is-empty) {
    error make {
      msg: "Command failed"
      label: {text: "Glob matched no file" span: $glob_span}
    }
  } else $in
  | recent $duration
  | if ($in | is-empty) {
    error make {
      msg: "Command failed"
      label: {text: "Given duration matched no file" span: $duration_span}
    } 
  } else $in
  | get name | each {|file|
    mv $file $dest
    {moved: ($file | path expand), to: ($dest | path expand)}
  }
  | if not $save {$in} else {$in | to nuon}
}

def --env test [] {
  let dir = $'/tmp/mv-recent-(random uuid)'
  mkdir $dir
  cd $dir
  mkdir goal
  touch test.file
  try { let _ = (mv-recent * goal 10sec) } catch {
    print $"(ansi rb)Test failed"
    cd -
    rm -r $dir
    return
  }
  print 'Test passed'
  cd -
  rm -r $dir
}
