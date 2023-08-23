export def "history recent" [
  dur: duration
  --max (-m): int = 1000
] {
  history | last $max | update start_timestamp {
    |col| $col.start_timestamp | into datetime
  } | where start_timestamp > ((date now) - $dur) | update start_timestamp {
    |col| $col.start_timestamp | date to-timezone local |
    format date "%F %T %Z"
  }
}
