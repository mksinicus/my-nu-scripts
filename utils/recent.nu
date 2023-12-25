# recent.nu

export def main [
  duration: duration
  --max (-m): int = 1000
] {
  let temp = [$in, (metadata $in).span]
  let tab = $temp.0
  let tab_span = $temp.1
  let duration_span = (metadata $duration).span

  match ($tab | columns) {
    $x if ('modified' in $x) => { # ls
      $tab | where modified <= (date now)
      | where modified > (date now) - $duration
    }
    $x if ('start_timestamp' in $x) => { # history
      $tab | update start_timestamp {|c| $c.start_timestamp | into datetime}
      | where start_timestamp <= (date now)
      | where start_timestamp > (date now) - $duration
      | update start_timestamp {|c| $c.start_timestamp | format date "%F %T %Z"}
    }
    _ => {
      error make {
        msg: "Invalid input"
        label: {
          text: "No applicable column found in table"
          span: $tab_span
        }
      }
    }
  }
}

