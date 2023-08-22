# better path relative-to using system `realpath`
export alias core-path-relative-to = path relative-to
export def "path relative-to" [
  path: path
]: string -> string {
  let relto = $in | path expand
  ^realpath -m --relative-to ($path | path expand) ($relto)
  | str trim
}

