# feed this function with something returned by `glob`.
export def main [files: any] {
  let span = (metadata $files).span
  let files = (
    match ($files | describe) {
      'string' => (glob $files)
      'list<string>' => $files
      _ => {
        panic {
          msg: "Parse failed"
          label: "Neither a string (glob pattern) nor a list"
          span: $span
        }
      }
    }
  )
  if false in ($files | str ends-with '.m3u8') {
    panic {
      msg: "Parse failed"
      label: "Some files don't have m3u8 extension, aborting"
      span: $span
    }
  }
  $files | par-each {
    |file|
    let basename = ($file | path parse | $in.parent + '/' + $in.stem)
    ffmpeg -i $file -c copy $'($basename).mp4'
  }
  return null
}

def panic [info] {
  error make {
    msg: $info.msg
    label: {
      text: $info.label
      start: $info.span.start
      end: $info.span.end
    }
  }
}
